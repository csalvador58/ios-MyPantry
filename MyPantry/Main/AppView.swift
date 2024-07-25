//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import CloudKit
import Models
import SwiftUI

@MainActor
struct AppView: View {
    @Environment(\.privateItemManager) var privateItemManager
    @Environment(\.sharedItemManager) var sharedItemManger
    @Environment(\.pantryService) var pantryService
    @State var viewModel = AppViewModel()

    @AppStorage("selectedPantryId") private var selectedPantryId: String?
    @AppStorage("cachedICloudUserId") private var cachedICloudUserId: String?

    var body: some View {
        if viewModel.isSignedInToiCloud {
            if let pantryId = selectedPantryId, !pantryId.isEmpty {
                mainView
            } else {
                SelectPantryView(viewModel: $viewModel)
            }
        } else {
            signInView
        }
    }

    private var mainView: some View {
        TabView {
            Text("Home View")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            Text("Pantry View")
                .tabItem {
                    Label("My Pantry", systemImage: "door.french.open")
                }
            AddItemView()
                .tabItem {
                    Label("Add Item", systemImage: "plus.app.fill")
                }
        }
        .withTheme()
    }

    private var signInView: some View {
        VStack {
            Link("Click to Sign In to your iCloud Account", destination: URL(string: "App-Prefs:root=CASTLE")!)

            if !viewModel.error.isEmpty {
                Text("Error: \(viewModel.error)")
                    .foregroundStyle(Color.red)
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
