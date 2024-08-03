//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import SwiftUI
import Models

@MainActor
struct PantryListView: View {
    @Environment(\.pantryService) private var pantryService
    @Bindable private var vm: PantryListViewModel
    @State private var sharingPantry: Pantry?
    @State private var isShowingShareSheet = false
    @State private var showCreatePantrySheet = false
    @AppStorage("selectedPantryId") private var selectedPantryId: String?
    
    init(viewModel: PantryListViewModel? = nil) {
        _vm = Bindable(viewModel ?? PantryListViewModel(pantryService: PantryService(containerIdentifier: Config.containerIdentifier)))
    }
    
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading pantries...")
                } else if vm.privatePantries.isEmpty && vm.sharedPantries.isEmpty {
                    Text("No pantries found. Create one to get started!")
                } else {
                    List {
                        Section("Private Pantries") {
                            ForEach(vm.privatePantries) { pantry in
                                pantryRow(pantry)
                            }
                        }
                        
                        Section("Shared Pantries") {
                            ForEach(vm.sharedPantries) { pantry in
                                pantryRow(pantry)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Pantries")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showCreatePantrySheet = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
        }
        .task {
            await vm.loadPantries()
        }
        .sheet(isPresented: $isShowingShareSheet) {
            if let pantry = sharingPantry {
                SharePantryView(pantry: pantry)
            }
        }
        .sheet(isPresented: $showCreatePantrySheet) {
            CreatePantryView { newPantry in
                Task {
                    await vm.loadPantries()
                }
            }
        }
        .alert("Error", isPresented: .constant(vm.error != nil), actions: {
            Button("OK") { vm.error = nil }
        }, message: {
            Text(vm.error ?? "An unknown error occurred")
        })
    }
    
    private func pantryRow(_ pantry: Pantry) -> some View {
        HStack {
            Text(pantry.name)
                .foregroundStyle(pantry.id == selectedPantryId ? .primaryColor : .adaptiveTextColor)
            Spacer()
            if pantry.isShared {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(.accent1Color)
            } else {
                Button("Share") {
                    sharingPantry = pantry
                    isShowingShareSheet = true
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedPantryId = pantry.id
        }
    }
}

#Preview("PantryListView - With Pantries") {
    let mockService = MockPantryService(
        privatePantries: [
            Pantry(id: "1", name: "Kitchen", ownerId: "user1", isShared: false),
            Pantry(id: "3", name: "Garage", ownerId: "user1", isShared: false)
        ],
        sharedPantries: [
            Pantry(id: "2", name: "Basement", ownerId: "user1", isShared: true)
        ]
    )
    return PantryListView()
        .environment(\.pantryService, mockService)
        .withTheme()
}

#Preview("PantryListView - Loading") {
    let mockService = MockPantryService(isLoading: true)
    return PantryListView()
        .environment(\.pantryService, mockService)
        .withTheme()
}

#Preview("PantryListView - Error") {
    let mockService = MockPantryService(error: "Failed to load pantries")
    return PantryListView()
        .environment(\.pantryService, mockService)
        .withTheme()
}

#Preview("PantryListView - Empty") {
    let mockService = MockPantryService()
    return PantryListView()
        .environment(\.pantryService, mockService)
        .withTheme()
}
