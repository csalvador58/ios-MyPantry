//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import Foundation
import Models
import Observation
import SwiftUI

@Observable
class AddItemViewModel {
    var name: String = ""
    var quantity: Int = 0
    var barcode: String = ""
    var isFavorite: Bool = false
    var expirationDate: Date = .now
    var notes: String = ""
    var hasExpirationDate: Bool = false
    var searchText: String = ""
    var searchResults: [String] = ["Apple", "Banana", "Orange", "Grapes", "Mango"]
    var showingPicker: Bool = false
    var selectedQuantity: Int = 1
    var isPickerVisible: Bool = false
    let range = 0 ... 100

    var filteredResults: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return searchResults.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    func clearQuantity() {
        quantity = 0
    }

    func saveItem() {
        // Implementation for saving the item
        print("Item Saved")
    }
}
