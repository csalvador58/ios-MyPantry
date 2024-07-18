//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import Models
import SwiftUI
import SwiftData

@main
struct MyPantryApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(\.privateItemManager, ItemManager(databaseType: .privateDB))
                .environment(\.sharedItemManager, ItemManager(databaseType: .sharedDB))
        }
    }
    
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
