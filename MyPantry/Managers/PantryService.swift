//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import Foundation
import Models
import SwiftUI

struct PantryServiceKey: EnvironmentKey {
    static let defaultValue = PantryService()
}

extension EnvironmentValues {
    var pantryService: PantryService {
        get { self[PantryServiceKey.self] }
        set { self[PantryServiceKey.self] = newValue }
    }
}

struct SharingInfo {
    let pantry: Pantry
    let shareId: String
}

protocol PantryServiceType {
    func savePantry(_ pantry: Pantry) async throws -> Pantry
    func fetchPantries(by ownerId: String) async throws -> [Pantry]
    func updatePantry(_ pantry: Pantry) async throws -> Pantry
    func deletePantry(_ pantry: Pantry) async throws
    func createSharedPantry(_ pantry: Pantry) async throws -> Pantry
    func fetchOrCreateShare(for pantry: Pantry) async throws -> SharingInfo
}

struct PantryService: PantryServiceType {
    private let cloudKitService: CloudKitServiceType
    
    init(cloudKitService: CloudKitServiceType = CloudKitService()) {
        self.cloudKitService = cloudKitService
    }
    
    func savePantry(_ pantry: Pantry) async throws -> Pantry {
        let record = PantryConverter.toRecord(pantry)
        let savedRecord = try await cloudKitService.saveRecord(record)
        guard let savedPantry = PantryConverter.fromRecord(savedRecord) else {
            throw PantryServiceError.failedToSavePantry
        }
        return savedPantry
    }
    
    func fetchPantries(by ownerId: String) async throws -> [Pantry] {
        let predicate = NSPredicate(format: "ownerId == %@", ownerId)
        let records = try await cloudKitService.fetchRecords(ofType: PantryConverter.recordType, withPredicate: predicate)
        return records.compactMap { PantryConverter.fromRecord($0) }
    }
    
    func updatePantry(_ pantry: Pantry) async throws -> Pantry {
        let record = PantryConverter.toRecord(pantry)
        let updatedRecord = try await cloudKitService.updateRecord(record)
        guard let updatedPantry = PantryConverter.fromRecord(updatedRecord) else {
            throw PantryServiceError.failedToUpdatePantry
        }
        return updatedPantry
    }
    
    func deletePantry(_ pantry: Pantry) async throws {
        let record = PantryConverter.toRecord(pantry)
        try await cloudKitService.deleteRecord(withID: record.recordID)
    }
    
    func createSharedPantry(_ pantry: Pantry) async throws -> Pantry {
        let sharedCloudKitPantry = try await cloudKitService.createSharedZone(for: pantry)
        guard let sharedPantry = PantryConverter.fromRecord(PantryConverter.toRecord(sharedCloudKitPantry)) else {
            throw PantryServiceError.failedToCreateSharedPantry
        }
        return sharedPantry
    }
    
    func fetchOrCreateShare(for pantry: Pantry) async throws -> SharingInfo {
        let (share, _) = try await cloudKitService.fetchOrCreateShare(for: pantry)
        return SharingInfo(pantry: pantry, shareId: share.recordID.recordName)
    }
}
