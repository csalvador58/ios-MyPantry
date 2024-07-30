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
    func fetchUserRecordID() async throws -> CKRecord.ID
    func createSharedZone(for pantry: Pantry) async throws -> Pantry
    func fetchOrCreateShare(for pantry: Pantry) async throws -> (CKShare, CKContainer)
    func acceptShare(metadata: CKShare.Metadata) async throws
    func saveRecord(_ record: CKRecord) async throws -> CKRecord
    func fetchRecords(ofType recordType: String, withPredicate predicate: NSPredicate) async throws -> [CKRecord]
    func updateRecord(_ record: CKRecord) async throws -> CKRecord
    func deleteRecord(withID recordID: CKRecord.ID) async throws
}

struct CloudKitService: CloudKitServiceType {
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    
    init(containerIdentifier: String = CKContainer.default().containerIdentifier ?? "") {
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

    func fetchUserRecordID() async throws -> CKRecord.ID {
        try await CKContainer.default().userRecordID()
        
    }
    
    func createSharedZone(for pantry: Pantry) async throws -> Pantry {
        let customZoneID = CKRecordZone.ID(zoneName: "SharedPantry-\(pantry.id)")
        let customZone = CKRecordZone(zoneID: customZoneID)
        
        _ = try await privateDatabase.modifyRecordZones(saving: [customZone], deleting: [])
        
        let updatedPantry = Pantry(
            id: pantry.id,
            name: pantry.name,
            ownerId: pantry.ownerId,
            shareReferenceId: nil,
            isShared: true,
            zoneId: customZoneID.zoneName
        )
        
        return updatedPantry
    }
    
    func fetchOrCreateShare(for pantry: Pantry) async throws -> (CKShare, CKContainer) {
        guard let zoneId = pantry.zoneId else {
            throw CloudKitError.sharedZoneNotFound
        }
        
        let customZoneID = CKRecordZone.ID(zoneName: zoneId)
        
        // Check if the zone exists
        let zone = try await privateDatabase.record(for: .init(zoneID: customZoneID))
        
        if let existingShare = zone.share {
            // If the zone has an existing share, fetch and return it
            let share = try await privateDatabase.record(for: existingShare.recordID) as? CKShare
            return (share ?? CKShare(recordZoneID: customZoneID), container)
        } else {
            // If no existing share, create a new one
            let share = CKShare(recordZoneID: customZoneID)
            share[CKShare.SystemFieldKey.title] = "Shared Pantry: \(pantry.name)"
            
            _ = try await privateDatabase.modifyRecords(saving: [share], deleting: [])
            
            return (share, container)
        }
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
    
    func fetchRecords(ofType recordType: String, withPredicate predicate: NSPredicate) async throws -> [CKRecord] {
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
    case sharedZoneCreationFailed = "Shared Zone Creation Failed"
    case sharedZoneNotFound = "Shared Zone Not Found"
    case shareCreationFailed = "Failed to Create Share"

    var errorDescription: String? {
        return self.rawValue
    }
}
