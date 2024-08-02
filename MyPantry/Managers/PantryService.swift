//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import Foundation
import CloudKit
import Models
import SwiftUI

struct PantryServiceKey: EnvironmentKey {
    nonisolated static let defaultValue = PantryService(containerIdentifier: Config.containerIdentifier)
}

extension EnvironmentValues {
    var pantryService: PantryService {
        get { self[PantryServiceKey.self] }
        set { self[PantryServiceKey.self] = newValue }
    }
}

struct SharingInfo {
    let pantry: Pantry
    let share: CKShare
}

protocol PantryServiceType {
    func fetchPantries() async throws -> (private: [Pantry], shared: [Pantry])
    func savePantry(_ pantry: Pantry, isShared: Bool) async throws -> Pantry
    func updatePantry(_ pantry: Pantry) async throws -> Pantry
    func deletePantry(_ pantry: Pantry) async throws
    func createSharedPantry(_ pantry: Pantry) async throws -> SharingInfo
    func acceptShareInvitation(metadata: CKShare.Metadata) async throws
}

@MainActor
struct PantryService: PantryServiceType {
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let sharedDatabase: CKDatabase
    private let sharedPantryPrefix = "SharedPantry"
    
    nonisolated init(containerIdentifier: String) {
        self.container = CKContainer(identifier: containerIdentifier)
        self.privateDatabase = container.privateCloudDatabase
        self.sharedDatabase = container.sharedCloudDatabase
    }
    
    func fetchPantries() async throws -> (private: [Pantry], shared: [Pantry]) {
        async let privatePantriesTask = fetchPantries(from: privateDatabase)
        async let sharedPantriesTask = fetchPantries(from: sharedDatabase)
        
        let (privatePantries, sharedPantries) = try await (privatePantriesTask, sharedPantriesTask)
        return (private: privatePantries, shared: sharedPantries)
    }
    
    private func fetchPantries(from database: CKDatabase) async throws -> [Pantry] {
        let zones = try await database.allRecordZones()
        var allPantries: [Pantry] = []
        
        for zone in zones where zone.zoneID != CKRecordZone.default().zoneID {
            let query = CKQuery(recordType: PantryConverter.recordType, predicate: NSPredicate(value: true))
            let queryOperation = CKQueryOperation(query: query)
            queryOperation.zoneID = zone.zoneID
            
            let (matchResults, _) = try await database.records(matching: query, inZoneWith: zone.zoneID, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults)
            let pantries = matchResults.compactMap { try? PantryConverter.fromRecord($0.1.get()) }
            allPantries.append(contentsOf: pantries)
        }
        
        return allPantries
    }
    
    func savePantry(_ pantry: Pantry, isShared: Bool) async throws -> Pantry {
        let record = PantryConverter.toRecord(pantry)
        let database = isShared ? sharedDatabase : privateDatabase
        let savedRecord = try await database.save(record)
        guard let savedPantry = PantryConverter.fromRecord(savedRecord) else {
            throw PantryServiceError.failedToSavePantry
        }
        return savedPantry
    }
    
    func updatePantry(_ pantry: Pantry) async throws -> Pantry {
        let record = PantryConverter.toRecord(pantry)
        let database = pantry.isShared ? sharedDatabase : privateDatabase
        let updatedRecord = try await database.save(record)
        guard let updatedPantry = PantryConverter.fromRecord(updatedRecord) else {
            throw PantryServiceError.failedToUpdatePantry
        }
        return updatedPantry
    }
    
    func deletePantry(_ pantry: Pantry) async throws {
        let record = PantryConverter.toRecord(pantry)
        let database = pantry.isShared ? sharedDatabase : privateDatabase
        try await database.deleteRecord(withID: record.recordID)
    }
    
    func createSharedPantry(_ pantry: Pantry) async throws -> SharingInfo {
        let zoneName = "\(sharedPantryPrefix)-\(pantry.id)"
        let customZoneID = CKRecordZone.ID(zoneName: zoneName)
        let customZone = CKRecordZone(zoneID: customZoneID)
        
        // Ensure the zone exists
        try await privateDatabase.save(customZone)
        
        let sharedPantry = Pantry(
            id: pantry.id,
            name: pantry.name,
            ownerId: pantry.ownerId,
            shareReferenceId: pantry.shareReferenceId,
            isShared: true,
            zoneId: zoneName
        )
        
        let recordID = CKRecord.ID(recordName: sharedPantry.id, zoneID: customZoneID)
        let record = CKRecord(recordType: PantryConverter.recordType, recordID: recordID)
        
        PantryConverter.setFields(for: record, from: sharedPantry)
        
        let savedRecord = try await privateDatabase.save(record)
        
        let (share, _) = try await fetchOrCreateShare(for: customZone)
        
        guard let savedPantry = PantryConverter.fromRecord(savedRecord) else {
            throw PantryServiceError.failedToCreateSharedPantry
        }
        
        return SharingInfo(pantry: savedPantry, share: share)
    }
    
    private func fetchOrCreateShare(for zone: CKRecordZone) async throws -> (CKShare, CKContainer) {
        if let existingShare = zone.share {
            guard let share = try await privateDatabase.record(for: existingShare.recordID) as? CKShare else {
                throw PantryServiceError.failedToCreateSharedPantry
            }
            return (share, container)
        } else {
            let share = CKShare(recordZoneID: zone.zoneID)
            share[CKShare.SystemFieldKey.title] = "Shared Pantry: \(zone.zoneID.zoneName)"
            _ = try await privateDatabase.modifyRecords(saving: [share], deleting: [])
            return (share, container)
        }
    }
    
    func acceptShareInvitation(metadata: CKShare.Metadata) async throws {
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
    
    // Helper method to fetch a single pantry by ID
    func fetchPantry(withID id: String, isShared: Bool) async throws -> Pantry {
        let database = isShared ? sharedDatabase : privateDatabase
        let recordID = CKRecord.ID(recordName: id)
        let record = try await database.record(for: recordID)
        
        guard let pantry = PantryConverter.fromRecord(record) else {
            throw PantryServiceError.failedToFetchPantry
        }
        
        return pantry
    }
    
    // Helper method to remove a user from a shared pantry
    func removeUserFromSharedPantry(_ userToRemove: CKUserIdentity, from pantry: Pantry) async throws {
        guard let zoneId = pantry.zoneId else {
            throw PantryServiceError.invalidPantryZone
        }
        
        let zoneID = CKRecordZone.ID(zoneName: zoneId)
        let shareRecordID = CKRecord.ID(recordName: "shareRecord", zoneID: zoneID)
        
        guard let share = try await privateDatabase.record(for: shareRecordID) as? CKShare else {
            throw PantryServiceError.failedToFetchShare
        }
        
        // Find the participant to remove
        guard let participantToRemove = share.participants.first(where: { $0.userIdentity == userToRemove }) else {
            throw PantryServiceError.userNotFound
        }
        
        // Remove the participant from the share
        share.removeParticipant(participantToRemove)
        
        // Save the updated share
        _ = try await privateDatabase.modifyRecords(saving: [share], deleting: [])
    }
    
    // Helper method to fetch all users for a shared pantry
    func fetchUsersForSharedPantry(_ pantry: Pantry) async throws -> [CKUserIdentity] {
        guard let zoneId = pantry.zoneId else {
            throw PantryServiceError.invalidPantryZone
        }
        
        let zoneID = CKRecordZone.ID(zoneName: zoneId)
        let shareRecordID = CKRecord.ID(recordName: "shareRecord", zoneID: zoneID)
        
        guard let share = try await privateDatabase.record(for: shareRecordID) as? CKShare else {
            throw PantryServiceError.failedToFetchShare
        }
        
        return share.participants.map { $0.userIdentity }
    }
}

class MockPantryService: PantryServiceType {
    private var state: State
    
    struct State {
        var privatePantries: [Pantry]
        var sharedPantries: [Pantry]
        var error: Error?
        var mockUsers: [String: [CKUserIdentity]]
    }
    
    init(privatePantries: [Pantry] = [],
         sharedPantries: [Pantry] = [],
         error: Error? = nil,
         mockUsers: [String: [CKUserIdentity]] = [:]) {
        self.state = State(
            privatePantries: privatePantries,
            sharedPantries: sharedPantries,
            error: error,
            mockUsers: mockUsers
        )
    }
    
    func fetchPantries() async throws -> (private: [Pantry], shared: [Pantry]) {
        if let error = state.error {
            throw error
        }
        return (state.privatePantries, state.sharedPantries)
    }
    
    func savePantry(_ pantry: Pantry, isShared: Bool) async throws -> Pantry {
        let newPantry = Pantry(
            id: UUID().uuidString,
            name: pantry.name,
            ownerId: pantry.ownerId,
            shareReferenceId: pantry.shareReferenceId,
            isShared: isShared,
            zoneId: pantry.zoneId
        )
        if isShared {
            state.sharedPantries.append(newPantry)
        } else {
            state.privatePantries.append(newPantry)
        }
        return newPantry
    }
    
    func updatePantry(_ pantry: Pantry) async throws -> Pantry {
        if pantry.isShared {
            if let index = state.sharedPantries.firstIndex(where: { $0.id == pantry.id }) {
                state.sharedPantries[index] = pantry
                return pantry
            }
        } else {
            if let index = state.privatePantries.firstIndex(where: { $0.id == pantry.id }) {
                state.privatePantries[index] = pantry
                return pantry
            }
        }
        throw PantryServiceError.failedToUpdatePantry
    }
    
    func deletePantry(_ pantry: Pantry) async throws {
        if pantry.isShared {
            state.sharedPantries.removeAll { $0.id == pantry.id }
        } else {
            state.privatePantries.removeAll { $0.id == pantry.id }
        }
    }
    
    func createSharedPantry(_ pantry: Pantry) async throws -> SharingInfo {
        let sharedPantry = Pantry(
            id: UUID().uuidString,
            name: pantry.name,
            ownerId: pantry.ownerId,
            shareReferenceId: UUID().uuidString,
            isShared: true,
            zoneId: "MockZone-\(UUID().uuidString)"
        )
        state.sharedPantries.append(sharedPantry)
        let mockShare = CKShare(recordZoneID: CKRecordZone.ID(zoneName: sharedPantry.zoneId ?? ""))
        return SharingInfo(pantry: sharedPantry, share: mockShare)
    }
    
    func acceptShareInvitation(metadata: CKShare.Metadata) async throws {
        // Simulate accepting a share invitation
    }
}
