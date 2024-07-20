//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import SwiftUI

@MainActor
struct AddItemView: View {
    @State private var viewModel = AddItemViewModel()
    @FocusState private var isSearchFocused: Bool
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(viewModel.filteredResults, id: \.self) { result in
                        Text(result)
                            .onTapGesture {
                                viewModel.name = result
                                viewModel.searchText = ""
                                isNameFocused = true
                            }
                    }
                }
                .listStyle(.plain)
                .frame(height: viewModel.filteredResults.isEmpty ? 0 : nil)

                Form {
                    AddItemDetailView(viewModel: viewModel, isNameFocused: $isNameFocused)

                    Section(header: Text("Item Notes")) {
                        TextEditor(text: $viewModel.notes)
                            .frame(height: 100)
                    }
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.saveItem()
                    }, label: {
                        Text("Save")
                        Image(systemName: "checkmark")
                            .foregroundColor(/*@START_MENU_TOKEN@*/ .blue/*@END_MENU_TOKEN@*/)
                            .imageScale(.large)
                    })
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search for items")
            .focused($isSearchFocused)
        }
    }
}

#Preview {
    AddItemView()
}
