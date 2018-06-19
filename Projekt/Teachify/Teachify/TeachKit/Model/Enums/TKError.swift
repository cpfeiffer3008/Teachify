//
//  TKError.swift
//  Firebase Playground
//
//  Created by Marcel Hagmann on 06.04.18.
//  Copyright © 2018 Marcel Hagmann. All rights reserved.
//

import Foundation
import CloudKit

enum TKError {
    case networkUnavailable
    case networkFailure
    case notAuthenticated
    
    case fetchSortTypeNotAvailable
    case noWritePermission
    case wrongRecordZone
    
    case noSharedData
    case objectIsFaulty
    case objectIsFaultyAfterCloudUpload
    case parentObjectIsFaulty
    
    case updateOperationFailed
    case deleteOperationFailed
    case createOperationFailed
    case addOperationFailed
    
    case failedSharing
    
    init?(ckError: CKError) {
        switch ckError.errorCode {
        case CKError.networkUnavailable.rawValue: self = .networkUnavailable
        case CKError.networkFailure.rawValue: self = .networkFailure
        case CKError.notAuthenticated.rawValue: self = .notAuthenticated
        default: return nil
        }
    }
}
