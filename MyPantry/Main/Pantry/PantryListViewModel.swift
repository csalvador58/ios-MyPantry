//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import Foundation
import Models
import SwiftUI

@MainActor
@Observable class PantryListViewModel {
    private let pantryService: PantryServiceType
    var privatePantries: [Pantry] = []
    var sharedPantries: [Pantry] = []
    var isLoading = false
    var error: String?
    
    init(pantryService: PantryServiceType) {
        self.pantryService = pantryService
    }
    
    func loadPantries() async {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            let (privatePantries, sharedPantries) = try await pantryService.fetchPantries()
            self.privatePantries = privatePantries
            self.sharedPantries = sharedPantries
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func createPantry(_ pantry: Pantry) async throws {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            let newPantry = try await pantryService.savePantry(pantry, isShared: pantry.isShared)
            if pantry.isShared {
                sharedPantries.append(newPantry)
            } else {
                privatePantries.append(newPantry)
            }
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func sharePantry(_ pantry: Pantry) async throws -> SharingInfo {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            let sharingInfo = try await pantryService.createSharedPantry(pantry)
            if let index = privatePantries.firstIndex(where: { $0.id == pantry.id }) {
                privatePantries.remove(at: index)
                sharedPantries.append(sharingInfo.pantry)
            }
            return sharingInfo
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
}
