//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import Models
import SwiftUI

@MainActor
@Observable class CreatePantryViewModel {
    private let pantryService: PantryServiceType
    var name: String = ""
    var isShared: Bool = false
    var isCreating: Bool = false
    var error: String?
    
    init(pantryService: PantryServiceType) {
        self.pantryService = pantryService
    }
    
    func createPantry() async throws -> Pantry {
        isCreating = true
        error = nil
        
        defer {
            isCreating = false
        }
        
        do {
            let newPantry: Pantry
            
            if isShared {
                let sharingInfo = try await pantryService.createSharedPantry(Pantry(name: name, ownerId: "", isShared: true))
                newPantry = sharingInfo.pantry
            } else {
                newPantry = try await pantryService.createPrivatePantry(Pantry(name: name, ownerId: "", isShared: false))
            }
            return newPantry
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
}

//class MockCreatePantryViewModel: CreatePantryViewModel {
//    override func createPantry() async throws -> Pantry {
//        // Simulate network delay
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        return Pantry(id: "mock", name: name, ownerId: "mockOwner", isShared: isShared)
//    }
//}
