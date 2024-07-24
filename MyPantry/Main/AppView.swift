//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import SwiftUI

@MainActor
struct AppView: View {
    @Environment(\.privateItemManager) var privateItemManager
    @Environment(\.sharedItemManager) var sharedItemManger
    @State var viewModel = AppViewModel()
    
    var body: some View {
        
        if viewModel.isSignedInToiCloud {
            ZStack {
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
            }
            .withTheme()
        } else {
            VStack {
                Link("Click to Sign In to your iCloud Account", destination: URL(string: "App-Prefs:root=CASTLE")!)
                
                if !viewModel.error.isEmpty {
                    Text("Error: \(viewModel.error)")
                        .foregroundStyle(Color.red)
                }
            }
        }
    }
}

#Preview("iCloud Not Enabled") {
    Group {
        let viewModel = MockAppViewModel(isIcloudEnabled: false)
        AppView(viewModel: viewModel)
    }
}

#Preview("iCloud Enabled") {
    Group {
        let viewModel = MockAppViewModel(isIcloudEnabled: true)
        AppView(viewModel: viewModel)
    }
}
