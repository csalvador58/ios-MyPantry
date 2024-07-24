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
    @State var myPantries: [Pantry] = []
    @State var isLoading: Bool = false
    @State var error: String?
    @State var showCreatePantryView: Bool = false

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

    private var pantrySelectionView: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else if myPantries.isEmpty {
                    VStack {
                        Text("No pantries found")
                        Button("Create New Pantry") {
                            showCreatePantryView = true
                        }
                    }
                } else {
                    List(myPantries) { pantry in
                        Button(pantry.name) {
                            selectedPantryId = pantry.id.recordName
                        }
                    }
                }

                if let error = error {
                    Text("Error: \(error)")
                        .foregroundStyle(Color.red)
                }
            }
            .navigationTitle("Select Pantry")
            .task {
                await loadPantries()
            }
            .sheet(isPresented: $showCreatePantryView) {
                CreatePantryView(viewModel: CreatePantryViewModel(), onComplete: { newPantry in
                    Task {
                        await createPantry(newPantry)
                    }
                })
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
            let ownerId = try await getICloudUserId()
            myPantries = try await pantryService.fetchPantry(by: ownerId)
            if myPantries.isEmpty {
                showCreatePantryView = true
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
            let ownerId = try await getICloudUserId()
            let newPantryWithOwner = Pantry(
                id: pantry.id,
                name: pantry.name,
                ownerId: ownerId,
                isShared: pantry.isShared
            )
            let newPantry = try await pantryService.addPantry(newPantryWithOwner, ownerId: ownerId)
            myPantries.append(newPantry)
            selectedPantryId = newPantry.id.recordName
            showCreatePantryView = false
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func getICloudUserId() async throws -> String {
        if let cachedId = cachedICloudUserId {
            return cachedId
        }
        let newId = try await fetchICloudUserId()
        cachedICloudUserId = newId
        return newId
    }

    private func fetchICloudUserId() async throws -> String {
        let container = CKContainer(identifier: Config.containerIdentifier)
        return try await container.userRecordID().recordName
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
