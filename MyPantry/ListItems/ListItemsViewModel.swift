//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import Models
import SwiftUI
import Observation

@Observable class ListItemsViewModel {
    var items: [Item] = []
    var selectedPantryId: String = "1234"
    
    func fetchItems(by pantryId: String) async {
        print("Items fetched")
        // TODO: fetch from item service
        self.items = []
    }
    
    func deleteItem(_ item: Item) async {
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
//        print("Created mock items: \(mockItems.count)")
        return mockItems.compactMap { $0 }
    }
    
    private func createMockItem(name: String, quantity: Int, status: ItemStatus, pantryId: String) -> Item? {
        let record = CKRecord(recordType: Item.type)
        record[Item.CodingKeys.name.rawValue] = name
        record[Item.CodingKeys.quantity.rawValue] = quantity
        record[Item.CodingKeys.favorite.rawValue] = false
        record[Item.CodingKeys.customContent1.rawValue] = ""
        record[Item.CodingKeys.customContent2.rawValue] = ""
        record[Item.CodingKeys.customContent3.rawValue] = ""
        record[Item.CodingKeys.dateAdded.rawValue] = Date()
        record[Item.CodingKeys.dateLastUpdated.rawValue] = Date()
        record[Item.CodingKeys.status.rawValue] = status.rawValue
        record[Item.CodingKeys.pantryId.rawValue] = pantryId
        
        let item = Item(record: record)
//        print("Created item: \(item != nil ? "success" : "failure") - \(name)")
        return item
    }
    
    override func fetchItems(by pantryId: String) async {
        print("Mock fetchItems called. Item count: \(items.count)")
    }
    
    override func deleteItem(_ item: Item) async {
        if let index = items.firstIndex(where: { $0.id?.recordName == item.id?.recordName }) {
            items.remove(at: index)
        }
    }
}
