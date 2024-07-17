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
        }
        .modelContainer(for: Item.self)
    }
    
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
