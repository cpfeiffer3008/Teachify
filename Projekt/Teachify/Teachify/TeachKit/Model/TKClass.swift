//
//  TKClass.swift
//  Firebase Playground
//
//  Created by Marcel Hagmann on 06.04.18.
//  Copyright © 2018 Marcel Hagmann. All rights reserved.
//

import Foundation
import CloudKit

struct TKClass: TKCloudObject {
    var subjects: [TKSubject] = []
    
    var name: String {
        didSet {
            record?[CloudKey.name] = name as CKRecordValue
        }
    }
    var creationDate: Date? {
        return record?.creationDate
    }
    
    var classID: String? {
        return record?.recordID.recordName
    }
    
    var record: CKRecord?
    
    var recordTypeID: String? {
        if var id = record?.recordID.recordName.replacingOccurrences(of: "-", with: "") {
            id.insert(contentsOf: "class", at: id.startIndex)
            return id
        }
        return nil
    }
    
    
    // MARK: - Initializer
    init(name: String) {
        self.name = name
    }
    
    init(record: CKRecord) {
        self.name = record[CloudKey.name] as? String ?? "TKClass-init-Error"
        self.record = record
    }
    
    mutating func append(subjects : [TKSubject]) {
        self.subjects.append(contentsOf: subjects)
    }
    
    
    // MARK: Keys
    struct CloudKey {
        private init() {}
        static let name = "name"
    }
    
}
