//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import Foundation
import Models
import SwiftUI
import os
 
@MainActor
@Observable class PantryViewModel {
    private let pantryService: PantryServiceType
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PantryViewModel")
    
    var createdPantries: [Pantry] = []
    var invitedPantries: [Pantry] = []
    var isLoading = false
    var error: String?
    var selectedPantry: Pantry?
    var isSharePresented = false
    var showCreatePantrySheet = false
    var sharingInfo: SharingInfo?
    
    init(pantryService: PantryServiceType) {
        self.pantryService = pantryService
    }
    
    func loadPantries() async {
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            let (privatePantries, sharedPantries) = try await pantryService.fetchPantries()
            let pantries = privatePantries + sharedPantries
            
            createdPantries = pantries.filter { $0.isShared }
            invitedPantries = pantries.filter { !$0.isShared }
            
            logger.info("Successfully loaded \(privatePantries.count) private and \(sharedPantries.count) shared pantries")
        } catch {
            logger.error("Failed to load pantries: \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
    }
    
    func initiateSharing(for pantry: Pantry) async {
        do {
            print("Initiating sharing for pantry: \(pantry)")
            sharingInfo = try await pantryService.createSharedPantry(pantry)
            isSharePresented = true
            print("Successfully created shared pantry: \(pantry.id)")
        } catch {
            logger.error("Failed to initiate sharing for pantry: \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
    }
    
//    func createPantry(_ pantry: Pantry) async throws {
//        isLoading = true
//        error = nil
//        
//        defer { isLoading = false }
//        
//        do {
//            let newPantry = try await pantryService.createPrivatePantry(pantry, isShared: pantry.isShared)
//            if pantry.isShared {
//                sharedPantries.append(newPantry)
//            } else {
//                privatePantries.append(newPantry)
//            }
//        } catch {
//            self.error = error.localizedDescription
//            throw error
//        }
//    }
//    
//    func sharePantry(_ pantry: Pantry) async throws -> SharingInfo {
//        isLoading = true
//        error = nil
//        
//        defer { isLoading = false }
//        
//        do {
//            let sharingInfo = try await pantryService.createSharedPantry(pantry)
//            if let index = privatePantries.firstIndex(where: { $0.id == pantry.id }) {
//                privatePantries.remove(at: index)
//                sharedPantries.append(sharingInfo.pantry)
//            }
//            return sharingInfo
//        } catch {
//            self.error = error.localizedDescription
//            throw error
//        }
//    }
}
