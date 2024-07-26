//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import CloudKit
import Foundation

protocol CloudKitServiceType {
    func verifyiCloudAvailability() async throws
    func fetchUserRecordID() async throws -> CKRecord.ID
}

struct CloudKitService: CloudKitServiceType {
    func verifyiCloudAvailability() async throws {
        async let accountStatus = CKContainer.default().accountStatus()
        async let userRecordID = CKContainer.default().userRecordID()
        
        switch try await accountStatus {
        case .available:
            _ = try await userRecordID
        case .couldNotDetermine:
            throw CloudKitError.iCloudAccountUnknown
        case .restricted:
            throw CloudKitError.iCloudAccountRestricted
        case .noAccount:
            throw CloudKitError.iCloudAccountNotFound
        case .temporarilyUnavailable:
            throw CloudKitError.iCloudAccountUnavailable
        @unknown default:
            throw CloudKitError.iCloudAccountOtherUnknown
        }
    }
    
    func fetchUserRecordID() async throws -> CKRecord.ID {
        try await CKContainer.default().userRecordID()
    }
}

enum CloudKitError: String, LocalizedError {
    case iCloudAccountUnknown = "Account Unknown"
    case iCloudAccountRestricted = "Account Restricted"
    case iCloudAccountNotFound = " Account Not Found"
    case iCloudAccountUnavailable = " Account Unavailable"
    case iCloudAccountOtherUnknown = "Account Service Error"
    
    var errorDescription: String? {
        return self.rawValue
    }
}
