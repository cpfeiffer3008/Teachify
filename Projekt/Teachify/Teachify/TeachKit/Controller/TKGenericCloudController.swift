//
//  GenericCloudController.swift
//  Teachify
//
//  Created by Marcel Hagmann on 17.04.18.
//  Copyright © 2018 Christian Pfeiffer. All rights reserved.
//

import Foundation
import CloudKit

// ✅
struct TKGenericCloudController<T: TKCloudObject> {

    private var database: CKDatabase

    private let privateDatabase = CKContainer.default().privateCloudDatabase
    
    /**
     Für **create()** notwendig
     */
    var zone: CKRecordZone
    
    /**
     Für **fetch()** notwendig
     */
    var recordZoneName: String
    
    init(zone: CKRecordZone, database: CKDatabase) {
        self.zone = zone
        self.recordZoneName = zone.zoneID.zoneName
        self.database = database
    }
    
    // ✅
    func fetch(forRecordType recordType: String,
               withFetchSortOptions fetchSortOptions: [TKFetchSortOption],
               predicate: NSPredicate,
               completion: @escaping ([T], TKError?) -> ()) {
        
        TKGenericCloudController.fetch(recordZone: recordZoneName, forDatabase: database) { (recordZone, error) in
            guard let recordZone = recordZone else {
                completion([], TKError.wrongRecordZone)
                return
            }
            
            let query = CKQuery(recordType: recordType, predicate: predicate)
            let sortDescriptors = fetchSortOptions.map { $0.sortDescriptor }
            query.sortDescriptors = sortDescriptors
            
            self.database.perform(query, inZoneWith: recordZone.zoneID, completionHandler: { (fetchedRecords, error) in
                let cloudObjects: [T] = fetchedRecords?.compactMap { T(record: $0) } ?? []
                completion(cloudObjects, nil)
            })
        }
    }
    
    // ✅
    func update(object: T, completion: @escaping (T?, TKError?) -> ()) {
        guard let record = object.record else {
            completion(nil, TKError.objectIsFaulty)
            return
        }
        
        database.save(record) { (savedRecord, error) in
            if let savedRecord = savedRecord, let cloudObject = T(record: savedRecord) {
                completion(cloudObject, nil)
            } else {
                print("TKGenericCloudController-update-Error: \(String(describing: error))")
                if let cloudError = error as? CKError, let tkError = TKError(ckError: cloudError) {
                    completion(nil, tkError)
                } else {
                    completion(nil, TKError.updateOperationFailed)
                }
            }
        }
    }
    
    // ✅
    func delete(object: T, completion: @escaping (TKError?) -> ()) {
        guard let record = object.record else {
            completion(TKError.objectIsFaulty)
            return
        }
        
        database.delete(withRecordID: record.recordID) { (deletedRecord, error) in
            if error == nil {
                completion(nil)
            } else {
                print("TKGenericCloudController-delete-Error: \(String(describing: error))")
                if let cloudError = error as? CKError, let tkError = TKError(ckError: cloudError) {
                    completion(tkError)
                } else {
                    completion(TKError.deleteOperationFailed)
                }
            }
        }
    }
    
    // ✅
    func remove(object: T, referenceKey: String, completion: @escaping (T?, TKError?) -> ()) {
        guard let record = object.record else {
            completion(nil, TKError.objectIsFaulty)
            return
        }
        
        record[referenceKey] = nil
        
        database.save(record) { (updatedRecord, error) in
            if error == nil {
                if let updatedRecord = updatedRecord, let cloudObject = T(record: updatedRecord) {
                    completion(cloudObject, nil)
                } else {
                    print("TKGenericCloudController-remove-Error: \(String(describing: error))")
                    if let cloudError = error as? CKError, let tkError = TKError(ckError: cloudError) {
                        completion(nil, tkError)
                    } else {
                        completion(nil, TKError.deleteOperationFailed)
                    }
                }
            } else {
                print("TKGenericCloudController-remove-Error: \(String(describing: error))")
                if let cloudError = error as? CKError, let tkError = TKError(ckError: cloudError) {
                    completion(nil, tkError)
                } else {
                    completion(nil, TKError.deleteOperationFailed)
                }
            }
        }
    }
    
    // ✅
    func add<K: TKCloudObject>(object: T, parentObject parent: K,
        withReferenceKey referenceKey: String, andAction action: CKReferenceAction, completion: @escaping (T?, TKError?) -> ()) {
        
        guard let parentRecord = parent.record, let objectRecord = object.record else {
            completion(nil, TKError.parentObjectIsFaulty)
            return
        }
        
        objectRecord[referenceKey] = CKReference(record: parentRecord, action: action)
        objectRecord.setParent(parentRecord)
        
        database.save(objectRecord) { (savedRecord, error) in
            if error == nil {
                if let savedRecord = savedRecord, let cloudObject = T(record: savedRecord) {
                    completion(cloudObject, nil)
                } else {
                    print("TKGenericCloudController-add-Error: \(String(describing: error))")
                    if let cloudError = error as? CKError, let tkError = TKError(ckError: cloudError) {
                        completion(nil, tkError)
                    } else {
                        completion(nil, TKError.addOperationFailed)
                    }
                }
            } else {
                print("TKGenericCloudController-add-Error: \(String(describing: error))")
                if let cloudError = error as? CKError, let tkError = TKError(ckError: cloudError) {
                    completion(nil, tkError)
                } else {
                    completion(nil, TKError.addOperationFailed)
                }
            }
        }
    }
    
    // ✅
    func create(object: T, completion: @escaping (T?, TKError?) -> ()) {
        var object = object
        
        database.save(zone) { (savedZone, error) in
            if let record = CKRecord(cloudObject: object, withRecordZoneID: self.zone.zoneID) {
                self.database.save(record) { (createdRecord, error) in
                    if error == nil {
                        object.record = createdRecord
                        completion(object, nil)
                    } else {
                        print("TKGenericCloudController-create-Error: \(String(describing: error))")
                        if let cloudError = error as? CKError, let tkError = TKError(ckError: cloudError) {
                            completion(nil, tkError)
                        } else {
                            completion(nil, TKError.createOperationFailed)
                        }
                    }
                    
                }
            } else {
                print("TKGenericCloudController-create-Error: \(String(describing: error))")
                completion(nil, TKError.wrongRecordZone)
            }
        }
    }
    
    
    // MARK: - Hilfsmethoden
    // ✅
    static func fetch(recordZone recordZoneName: String, forDatabase database: CKDatabase, completion: @escaping (CKRecordZone?, TKError?) -> ()) {
        
        database.fetchAllRecordZones { (recordZones, error) in
            guard let recordZones = recordZones else {
                print("TKGenericCloudController-fetchRecordZone-Error: \(String(describing: error))")
                completion(nil, TKError.wrongRecordZone)
                return
            }
            
            let classRecordZones = recordZones.compactMap { $0.zoneID.zoneName == recordZoneName ? $0 : nil }
            guard let classRecordZone = classRecordZones.first else {
                print("TKGenericCloudController-fetchRecordZone-Error: \(String(describing: error))")
                completion(nil, TKError.wrongRecordZone)
                return
            }
            
            completion(classRecordZone, nil)
        }
    }
    
    // ✅
    static func fetch(recordZone recordZoneName: String, forDatabase database: CKDatabase) -> CKRecordZone? {
        var result: CKRecordZone? = nil
        
        let group = DispatchGroup()
        group.enter()
        
        fetch(recordZone: recordZoneName, forDatabase: database) { (fetchedRecordZone, error) in
            result = fetchedRecordZone
            group.leave()
        }
        
        group.wait()
        
        return result
    }

}
