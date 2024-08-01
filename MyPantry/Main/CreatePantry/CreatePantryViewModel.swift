//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import Models
import SwiftUI

@Observable class CreatePantryViewModel {
    var name: String = ""
    var isShared: Bool = false
    var isCreating: Bool = false
    var error: String?

    private let pantryService: PantryServiceType
    
    init(pantryService: PantryServiceType = PantryService()) {
        self.pantryService = pantryService
    }
    
    func createPantry() async throws -> Pantry {
        isCreating = true
        error = nil
        
        defer {
            isCreating = false
        }
        
        do {
            let newPantry = try await pantryService.savePantry(
                Pantry(name: name, ownerId: "", isShared: isShared),
                isShared: isShared
            )
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
