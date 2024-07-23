//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import SwiftUI

struct AppView: View {
    @Environment(\.privateItemManager) var privateItemManager
    @Environment(\.sharedItemManager) var sharedItemManger
    var body: some View {
        ZStack {
            
        }
        TabView {
            Text("Home View")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            Text("Pantry View")
                .tabItem {
                    Label("My Pantry", systemImage: "door.french.open")
                }
            Text("Add Item View")
                .tabItem {
                    Label("Add Item", systemImage: "plus.app.fill")
                }
        }
        .withTheme()
    }
}

#Preview {
    AppView()
}
