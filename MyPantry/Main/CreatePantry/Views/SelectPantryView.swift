//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import CloudKit
import Models
import SwiftUI

@MainActor
struct SelectPantryView: View {
    @Environment(\.pantryService) var pantryService
    @Binding var viewModel: AppViewModel

    @AppStorage("selectedPantryId") private var selectedPantryId: String?
    @AppStorage("cachedICloudUserId") private var cachedICloudUserId: String?

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.myPantries.isEmpty {
                    VStack {
                        Text("No pantries found")
                        Text("iCloud User Record ID: \(viewModel.userRecordId ?? "Not Available")")
                        Text("iCloud has icloud account: \(viewModel.hasIcloudAccount ? "True" : "False")")
                        Text("iCloud username: \(viewModel.userName ?? "Not Available")")
                        Button("Create New Pantry") {
                            viewModel.showCreatePantryView = true
                        }
                    }
                } else {
                    List(viewModel.myPantries) { pantry in
                        Button(pantry.name) {
                            selectedPantryId = pantry.id.recordName
                        }
                    }
                }

                if !viewModel.error.isEmpty {
                    Text("Error: \(viewModel.error)")
                        .foregroundStyle(Color.red)
                }
            }
            .navigationTitle("Select Pantry")
            .task {
                await loadPantries()
            }
            .sheet(isPresented: $viewModel.showCreatePantryView) {
                CreatePantryView(viewModel: CreatePantryViewModel(), onComplete: { newPantry in
                    Task {
                        await createPantry(newPantry)
                    }
                })
            }
        }
    }

    private func loadPantries() async {
        viewModel.isLoading = true
        viewModel.error = ""
        do {
            let ownerId = try await getICloudUserId()
            viewModel.myPantries = try await pantryService.fetchPantry(by: ownerId)
            if viewModel.myPantries.isEmpty {
                viewModel.showCreatePantryView = true
            }
        } catch {
            viewModel.error = error.localizedDescription
        }
        viewModel.isLoading = false
    }

    private func createPantry(_ pantry: Pantry) async {
        viewModel.isLoading = true
        viewModel.error = ""
        do {
            let ownerId = try await getICloudUserId()
            let newPantryWithOwner = Pantry(
                id: pantry.id,
                name: pantry.name,
                ownerId: ownerId,
                isShared: pantry.isShared
            )
            let newPantry = try await pantryService.addPantry(newPantryWithOwner, ownerId: ownerId)
            viewModel.myPantries.append(newPantry)
            selectedPantryId = newPantry.id.recordName
            viewModel.showCreatePantryView = false
        } catch {
            viewModel.error = error.localizedDescription
        }
        viewModel.isLoading = false
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
