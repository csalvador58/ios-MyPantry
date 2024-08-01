//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import Foundation
import Models
import SwiftUI

@Observable class SelectPantryViewModel {
    var privatePantries: [Pantry] = []
    var sharedPantries: [Pantry] = []
    var isLoading = false
    var error: String?
    
    private let pantryService: PantryServiceType
    
    init(pantryService: PantryServiceType = PantryService()) {
        self.pantryService = pantryService
    }
    
    func loadPantries() async {
        isLoading = true
        error = nil
        do {
            let (privatePantries, sharedPantries) = try await pantryService.fetchPantries()
            await MainActor.run {
                self.privatePantries = privatePantries
                self.sharedPantries = sharedPantries
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

@Observable class MockSelectPantryViewModel: SelectPantryViewModel {
    override func loadPantries() async {
        // Do nothing for the mock
    }
}
