//
//  TKSubjectController.swift
//  Teachify
//
//  Created by Marcel Hagmann on 16.04.18.
//  Copyright © 2018 Christian Pfeiffer. All rights reserved.
//

import Foundation
import CloudKit

struct TKSubjectController {
    
    var cloudCtrl: TKGenericCloudController<TKSubject>!
    var rank: TKRank!
    
    mutating func initialize(withRank rank: TKRank, completion: @escaping (TKError?) -> ()) {
        self.rank = rank
        
        switch rank {
        case .student:
            if let recordZone = TKGenericCloudController<TKSubject>.fetch(recordZone: CKRecordZone.teachKitZone.zoneID.zoneName,
                                                                          forDatabase: CKContainer.default().sharedCloudDatabase) {
                self.cloudCtrl = TKGenericCloudController<TKSubject>(zone: recordZone, database: rank.database)
                completion(nil)
            } else {
                completion(TKError.noSharedData)
            }
        case .teacher:
            cloudCtrl = TKGenericCloudController<TKSubject>(zone: CKRecordZone.teachKitZone, database: rank.database)
            completion(nil)
        }
    }
    
    // MARK: - Subject Operations
    // ✅
    func fetchSubject(forClass tkClass: TKClass? = nil,
                      withFetchSortOptions fetchSortOptions: [TKFetchSortOption] = [],
                      completion: @escaping ([TKSubject], TKError?) -> ()) {
        
        var predicate = NSPredicate(format: "TRUEPREDICATE")
        if let classRecord = tkClass?.record {
            predicate = NSPredicate(format: "%K == %@", TKSubject.CloudKey.referenceToClass, CKReference(record: classRecord, action: CKReferenceAction.none))
        }
        
        cloudCtrl.fetch(forRecordType: TKCloudKey.RecordType.subjectes, withFetchSortOptions: fetchSortOptions, predicate: predicate) { (fetchedSubjects, error) in
            completion(fetchedSubjects, error)
        }
    }
    
    // ✅
    func add(subject: TKSubject, toTKClass tkClass: TKClass, completion: @escaping (TKSubject?, TKError?) -> ()) {
        cloudCtrl.create(object: subject) { (createdSubject, error) in
            guard let createdSubject = createdSubject else {
                completion(nil, TKError.objectIsFaultyAfterCloudUpload)
                return
            }
            
            self.cloudCtrl.add(object: createdSubject,
                               parentObject: tkClass,
                               withReferenceKey: TKSubject.CloudKey.referenceToClass,
                               andAction: CKReferenceAction.deleteSelf,
                               completion: { (subject, error) in
                completion(subject, error)
            })
        }
    }
    
    // ✅
    func update(subject: TKSubject, completion: @escaping (TKSubject?, TKError?) -> ()) {
        cloudCtrl.update(object: subject) { (updatedSubject, error) in
            completion(updatedSubject, error)
        }
    }
    
    // ✅
    func delete(subject: TKSubject, completion: @escaping (TKError?) -> ()) {
        cloudCtrl.delete(object: subject) { (error) in
            completion(error)
        }
    }
    
    
    // MARK: Hilfsmethoden
}





