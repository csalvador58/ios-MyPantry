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
    @State var myPantry: [Pantry] = []
    @State var isLoading: Bool = false
    @State var error: String?

    @AppStorage("selectedPantryId") private var selectedPantryId: String?
    @AppStorage("cachedICloudUserId") private var cachedICloudUserId: String?

    var body: some View {
        if viewModel.isSignedInToiCloud {
            if let selectedPantryId = selectedPantryId {
                mainView
            } else {
                pantrySelectionView
            }
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

    private var pantrySelectionView: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if myPantry.isEmpty {
                createPantryView
            } else {
                List(myPantry) { pantry in
                    Button(pantry.name) {
                        selectedPantryId = pantry.id?.recordName
                    }
                }
            }

            if let error = error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
        }
    }

    private var createPantryView: some View {
        CreatePantryView { newPantry in
            Task {
                await createPantry(newPantry)
            }
        }
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

    private func loadPantries() async {
        isLoading = true
        error = nil
        do {
            let ownerId = try await fetchICloudUserId()
            myPantry = try await pantryService.fetchPantry(by: ownerId)
            if let firstPantry = myPantry.first {
                selectedPantryId = firstPantry.id?.recordName
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func createPantry(_ pantry: Pantry) async {
        isLoading = true
        error = nil
        do {
            let ownerId = try await fetchICloudUserId()
            let newPantryWithOwner = Pantry(
                id: pantry.id,
                name: pantry.name,
                ownerId: ownerId
            )
            let newPantry = try await pantryService.addPantry(newPantryWithOwner, ownerId: ownerId)
            myPantry.append(newPantry)
            selectedPantryId = newPantry.id?.recordName
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func fetchICloudUserId() async throws -> String {
        let container = CKContainer(identifier: Config.containerIdentifier)
        return try await container.userRecordID().recordName
    }

    private func getICloudUserId() async throws -> String {
        if let cachedId = cachedICloudUserId {
            return cachedId
        }
        let newId = try await fetchICloudUserId()
        cachedICloudUserId = newId
        return newId
    }
}

struct CreatePantryView: View {
    @State private var pantryName = ""
    var onCreatePantry: (Pantry) -> Void

    var body: some View {
        Form {
            TextField("Pantry Name", text: $pantryName)
            Button("Create Pantry") {
                let newPantry = Pantry(name: pantryName, ownerId: "") // Empty string for ownerId
                onCreatePantry(newPantry)
            }
            .disabled(pantryName.isEmpty)
        }
    }
}

// #Preview("iCloud Not Enabled") {
//    Group {
//        let viewModel = MockAppViewModel(isIcloudEnabled: false)
//        AppView(viewModel: viewModel)
//    }
// }
//
// #Preview("iCloud Enabled") {
//    Group {
//        let viewModel = MockAppViewModel(isIcloudEnabled: true)
//        AppView(viewModel: viewModel)
//    }
// }
