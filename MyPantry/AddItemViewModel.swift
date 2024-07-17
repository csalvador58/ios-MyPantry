//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import Foundation
import Models

@Observable
class AddItemViewModel {
    private var db = CKContainer(identifier: Config.containerIdentifier).privateCloudDatabase
    private var itemDictionary: [CKRecord.ID: Item] = [:]
    
    var pantryItem: [Item] {
        itemDictionary.values.compactMap { $0 }
    }
    
    func addItem(to pantryID: String, item: Item) async throws {
        
    }
    
    
}
