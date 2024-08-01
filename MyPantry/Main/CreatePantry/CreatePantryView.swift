//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import Models
import SwiftUI
import UIKit

struct CreatePantryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pantryService) private var pantryService
    @State private var vm: CreatePantryViewModel
    let onCreate: (Pantry) -> Void
    
    init(onCreate: @escaping (Pantry) -> Void) {
        _vm = State(initialValue: CreatePantryViewModel())
        self.onCreate = onCreate
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Pantry Details")) {
                    TextField("Pantry Name", text: $vm.name)
                }
                
                Section(header: Text("Sharing")) {
                    Toggle("Share Pantry", isOn: $vm.isShared)
                }
                
                Section {
                    Button(action: createPantry, label: {
                        if vm.isCreating {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Create Pantry")
                                .frame(maxWidth: .infinity)
                        }
                    })
                    .disabled(vm.name.isEmpty || vm.isCreating)
                    .padding()
                    .background(vm.name.isEmpty ? Color.secondaryColor : Color.primaryColor)
                    .foregroundStyle(.adaptiveButtonTextColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .navigationTitle("Create New Pantry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.primaryColor)
                }
            })
        }
        .alert("Error", isPresented: .constant(vm.error != nil), actions: {
            Button("OK") { vm.error = nil }
        }, message: {
            Text(vm.error ?? "An unknown error occurred")
        })
        .withTheme()
    }
    
    private func createPantry() {
        Task {
            do {
                let newPantry = try await vm.createPantry()
                onCreate(newPantry)
                dismiss()
            } catch {
                // Error is already handled in view model
            }
        }
    }
}

#Preview("Light Mode") {
    CreatePantryView { _ in }
        .withTheme()
}

#Preview("Dark Mode") {
    CreatePantryView { _ in }
        .withTheme()
        .preferredColorScheme(.dark)
}
