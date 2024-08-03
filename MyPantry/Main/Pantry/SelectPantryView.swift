//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import SwiftUI
import Models

@MainActor
struct SelectPantryView: View {
    @Environment(\.pantryService) private var pantryService
    @Bindable private var vm: SelectPantryViewModel
    @State private var showCreatePantrySheet = false
    @AppStorage("selectedPantryId") private var selectedPantryId: String?
    
    init(viewModel: SelectPantryViewModel? = nil) {
        _vm = Bindable(viewModel ?? SelectPantryViewModel(pantryService: PantryService(containerIdentifier: Config.containerIdentifier)))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    VStack {
                        ProgressView("Loading...")
                    }
                } else if vm.privatePantries.isEmpty && vm.sharedPantries.isEmpty {
                    VStack {
                        Text("No pantries found")
                            .foregroundStyle(.adaptiveTextColor)
                        Text("Create a new pantry to get started")
                            .foregroundStyle(.adaptiveTextColor)
                        Button {
                            showCreatePantrySheet = true
                        } label: {
                            Text("Create Pantry")
                                .padding()
                                .background(.primaryColor)
                                .foregroundStyle(.adaptiveButtonTextColor)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                        }
                    }
                } else {
                    pantriesList
                }
            }
            .navigationTitle("Select Pantry")
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showCreatePantrySheet = true
                    }, label: {
                        Label(
                            title: { Text("Add Pantry") },
                            icon: {
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(.accent2Color, .accent1Color)
                            }
                        )
                    })
                    .disabled(vm.isLoading)
                }
            })
        }
        .task {
            await vm.loadPantries()
        }
        .alert("Error", isPresented: .constant(vm.error != nil), actions: {
            Button("OK") {
                vm.error = nil
            }
        }, message: {
            Text(vm.error ?? "An unknown error occurred")
        })
        .sheet(isPresented: $showCreatePantrySheet, content: {
            CreatePantryView { newPantry in
                Task {
                    await vm.loadPantries()
                    selectedPantryId = newPantry.id
                }
                
            }
        })
        .withTheme()
    }
    
    private var pantriesList: some View {
        List {
            if !vm.privatePantries.isEmpty {
                Section("Private Pantries") {
                    ForEach(vm.privatePantries) { pantry in
                        pantryRow(pantry)
                    }
                }
            }
            if !vm.sharedPantries.isEmpty {
                Section("Shared Pantries") {
                    ForEach(vm.sharedPantries) { pantry in
                        pantryRow(pantry)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func pantryRow(_ pantry: Pantry) -> some View {
        Button {
            selectedPantryId = pantry.id
        } label: {
            HStack {
                Text(pantry.name)
                    .foregroundStyle(.adaptiveTextColor)
                Spacer()
                if pantry.isShared {
                    Image(systemName: "person.2")
                        .foregroundStyle(.accent1Color)
                }
            }
        }
    }
}

#Preview("With Pantries (Light)") {
    let mockService = MockPantryService(
        privatePantries: [
            Pantry(id: "1", name: "My Pantry", ownerId: "user1", isShared: false),
            Pantry(id: "2", name: "Kitchen", ownerId: "user1", isShared: false)
        ],
        sharedPantries: [
            Pantry(id: "3", name: "Family Pantry", ownerId: "user2", isShared: true)
        ],
        isLoading: false
    )
    return SelectPantryView(viewModel: SelectPantryViewModel(pantryService: mockService))
        .withTheme()
        .preferredColorScheme(.light)
}

#Preview("With Pantries (Dark)") {
    let mockService = MockPantryService(
        privatePantries: [
            Pantry(id: "1", name: "My Pantry", ownerId: "user1", isShared: false),
            Pantry(id: "2", name: "Kitchen", ownerId: "user1", isShared: false)
        ],
        sharedPantries: [
            Pantry(id: "3", name: "Family Pantry", ownerId: "user2", isShared: true)
        ],
        isLoading: false
    )
    return SelectPantryView(viewModel: SelectPantryViewModel(pantryService: mockService))
        .withTheme()
        .preferredColorScheme(.dark)
}

#Preview("Loading") {
    let mockService = MockPantryService(isLoading: true)
    return SelectPantryView(viewModel: SelectPantryViewModel(pantryService: mockService))
        .withTheme()
}

#Preview("No Pantries") {
    let mockService = MockPantryService()
    return SelectPantryView(viewModel: SelectPantryViewModel(pantryService: mockService))
        .withTheme()
}

#Preview("Error") {
    let mockService = MockPantryService(error: "Failed to load pantries")
    return SelectPantryView(viewModel: SelectPantryViewModel(pantryService: mockService))
        .withTheme()
}
