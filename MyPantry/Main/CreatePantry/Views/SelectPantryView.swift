//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import SwiftUI
import Models

struct SelectPantryView: View {
    @Environment(\.pantryService) private var pantryService
    @State private var vm: SelectPantryViewModel
    @AppStorage("selectedPantryId") private var selectedPantryId: String?
    
    init(viewModel: SelectPantryViewModel = SelectPantryViewModel()) {
        _vm = State(initialValue: viewModel)
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
                        Text("Create a new pantry to get started")
                    }
                } else {
                    pantriesList
                }
            }
            .navigationTitle("Select Pantry")
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
    }
    
    private func pantryRow(_ pantry: Pantry) -> some View {
        Button {
            selectedPantryId = pantry.id
        } label: {
            HStack {
                Text(pantry.name)
                Spacer()
                if pantry.isShared {
                    Image(systemName: "person.2")
                }
            }
        }
    }
}

#Preview("With Pantries") {
    let mockVM = MockSelectPantryViewModel()
    mockVM.privatePantries = [
        Pantry(id: "1", name: "My Pantry", ownerId: "user1", isShared: false),
        Pantry(id: "2", name: "Kitchen", ownerId: "user1", isShared: false)
    ]
    mockVM.sharedPantries = [
        Pantry(id: "3", name: "Family Pantry", ownerId: "user2", isShared: true)
    ]
    return SelectPantryView(viewModel: mockVM)
}

#Preview("Loading") {
    let mockVM = MockSelectPantryViewModel()
    mockVM.isLoading = true
    return SelectPantryView(viewModel: mockVM)
}

#Preview("No Pantries") {
    SelectPantryView(viewModel: MockSelectPantryViewModel())
}

#Preview("Error") {
    let mockVM = MockSelectPantryViewModel()
    mockVM.error = "Failed to load pantries"
    return SelectPantryView(viewModel: mockVM)
}
