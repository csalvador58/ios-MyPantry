//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import CloudKit
import Foundation
import Models

protocol CloudKitServiceType {
    func verifyiCloudAvailability() async throws
    func fetchUserRecordID() async throws -> String
    func acceptShare(metadata: CKShare.Metadata) async throws
    func saveRecord(_ record: CKRecord) async throws -> CKRecord
    func fetchRecords(ofType recordType: String, withPredicate predicate: NSPredicate) async throws -> [CKRecord]
    func updateRecord(_ record: CKRecord) async throws -> CKRecord
    func deleteRecord(withID recordID: CKRecord.ID) async throws
}

@MainActor
struct CloudKitService: CloudKitServiceType {
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    
    nonisolated init(containerIdentifier: String = CKContainer.default().containerIdentifier ?? "") {
        self.container = CKContainer(identifier: containerIdentifier)
        self.privateDatabase = self.container.privateCloudDatabase
    }
    
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

    func fetchUserRecordID() async throws -> String {
        let recordID = try await CKContainer.default().userRecordID()
        return recordID.recordName
    }
    
    func acceptShare(metadata: CKShare.Metadata) async throws {
        let operation = CKAcceptSharesOperation(shareMetadatas: [metadata])
        
        return try await withCheckedThrowingContinuation { continuation in
            operation.perShareResultBlock = { metadata, result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success:
                    continuation.resume()
                }
            }
            
            operation.qualityOfService = .utility
            container.add(operation)
        }
    }
    
    func saveRecord(_ record: CKRecord) async throws -> CKRecord {
        try await privateDatabase.save(record)
    }
    
    nonisolated func fetchRecords(ofType recordType: String, withPredicate predicate: NSPredicate) async throws -> [CKRecord] {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let (matchResults, _) = try await privateDatabase.records(matching: query)
        return matchResults.compactMap { try? $0.1.get() }
    }
    
    func updateRecord(_ record: CKRecord) async throws -> CKRecord {
        try await privateDatabase.save(record)
    }
    
    func deleteRecord(withID recordID: CKRecord.ID) async throws {
        try await privateDatabase.deleteRecord(withID: recordID)
    }
}

enum CloudKitError: String, LocalizedError {
    case iCloudAccountUnknown = "Account Unknown"
    case iCloudAccountRestricted = "Account Restricted"
    case iCloudAccountNotFound = " Account Not Found"
    case iCloudAccountUnavailable = " Account Unavailable"
    case iCloudAccountOtherUnknown = "Account Service Error"
    case conversionFailed = "Conversion Failed"
    
    var errorDescription: String? {
        return self.rawValue
    }
}

class MockCloudKitService: CloudKitServiceType {
    var shouldSucceed: Bool
    var mockUserRecordID: String
    
    init(shouldSucceed: Bool = true, mockUserRecordID: String = "mock-user-id") {
        self.shouldSucceed = shouldSucceed
        self.mockUserRecordID = mockUserRecordID
    }
    
    func verifyiCloudAvailability() async throws {
        if !shouldSucceed {
            throw CloudKitError.iCloudAccountNotFound
        }
    }
    
    func fetchUserRecordID() async throws -> String {
        if shouldSucceed {
            return mockUserRecordID
        } else {
            throw CloudKitError.iCloudAccountNotFound
        }
    }
    
    func acceptShare(metadata: CKShare.Metadata) async throws {
        if !shouldSucceed {
            throw CloudKitError.iCloudAccountNotFound
        }
    }
    
    func saveRecord(_ record: CKRecord) async throws -> CKRecord {
        if shouldSucceed {
            return record
        } else {
            throw CloudKitError.iCloudAccountNotFound
        }
    }
    
    func fetchRecords(ofType recordType: String, withPredicate predicate: NSPredicate) async throws -> [CKRecord] {
        if shouldSucceed {
            return []
        } else {
            throw CloudKitError.iCloudAccountNotFound
        }
    }
    
    func updateRecord(_ record: CKRecord) async throws -> CKRecord {
        if shouldSucceed {
            return record
        } else {
            throw CloudKitError.iCloudAccountNotFound
        }
    }
    
    func deleteRecord(withID recordID: CKRecord.ID) async throws {
        if !shouldSucceed {
            throw CloudKitError.iCloudAccountNotFound
        }
    }
}
