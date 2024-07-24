//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import Models
import Observation
import SwiftUI

@Observable class ListItemsViewModel {
    var items: [Item] = []
    var selectedPantryId: String = "1234"

    func fetchItems(by _: String) async {
        print("Items fetched")
        // TODO: fetch from item service
        self.items = []
    }

    func deleteItem(_: Item) async {
        print("Item deleted")
    }
}

class MockListItemsViewModel: ListItemsViewModel {
    override init() {
        super.init()
        self.items = createMockItems()
    }

    private func createMockItems() -> [Item] {
        let mockItems = [
            createMockItem(name: "Apples", quantity: 5, status: .inStock, pantryId: "pantry1"),
            createMockItem(name: "Milk", quantity: 1, status: .lowStock, pantryId: "pantry1"),
            createMockItem(name: "Bread", quantity: 2, status: .inStock, pantryId: "pantry1"),
            createMockItem(name: "Eggs", quantity: 12, status: .lowStock, pantryId: "pantry1"),
            createMockItem(name: "Cheese", quantity: 1, status: .outOfStock, pantryId: "pantry1")
        ]
        return mockItems
    }

    private func createMockItem(name: String, quantity: Int, status: ItemStatus, pantryId: String) -> Item {
        return Item(
            id: CKRecord.ID(recordName: UUID().uuidString),
            name: name,
            quantity: quantity,
            quantityDesired: nil,
            barcode: nil,
            favorite: false,
            customContent1: "",
            customContent2: "",
            customContent3: "",
            dateAdded: Date(),
            dateLastUpdated: Date(),
            expireDate: nil,
            note: nil,
            pantryId: pantryId,
            status: status
        )
    }

    override func fetchItems(by _: String) async {
        print("Mock fetchItems called. Item count: \(items.count)")
    }

    override func deleteItem(_ item: Item) async {
        if let index = items.firstIndex(where: { $0.id?.recordName == item.id?.recordName }) {
            items.remove(at: index)
        }
    }
}
