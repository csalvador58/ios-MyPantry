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
//    func savePantry(_ pantry: Pantry) async throws -> Pantry
//    func fetchPantry(withId id: String) async throws -> Pantry
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
        
        return try await createSharedZoneAsync(for: pantry, customZoneID: customZoneID, customZone: customZone)
    }
    
    private func createSharedZoneAsync(for pantry: Pantry, customZoneID: CKRecordZone.ID, customZone: CKRecordZone) async throws -> Pantry {
        try await withUnsafeThrowingContinuation { continuation in
            createSharedZoneHelper(for: pantry, customZoneID: customZoneID, customZone: customZone) { (result: Result<Pantry, Error>) in
                continuation.resume(with: result)
            }
        }
    }
    
    private func createSharedZoneHelper(for pantry: Pantry, customZoneID: CKRecordZone.ID, customZone: CKRecordZone, completion: @escaping (Result<Pantry, Error>) -> Void) {
        privateDatabase.modifyRecordZones(saving: [customZone], deleting: []) { (result: Result<(saveResults: [CKRecordZone.ID: Result<CKRecordZone, Error>], deleteResults: [CKRecordZone.ID: Result<Void, Error>]), Error>) in
            switch result {
            case .success(let saveResults):
                if let zoneResult = saveResults.saveResults[customZoneID], case .success = zoneResult {
                    let updatedPantry = Pantry(
                        id: pantry.id,
                        name: pantry.name,
                        ownerId: pantry.ownerId,
                        shareReferenceId: nil,
                        isShared: true,
                        zoneId: customZoneID.zoneName
                    )
                    completion(.success(updatedPantry))
                } else {
                    completion(.failure(CloudKitError.sharedZoneCreationFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
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

    var errorDescription: String? {
        return self.rawValue
    }
}
