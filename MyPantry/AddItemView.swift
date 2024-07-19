//
//  AddItemView.swift
//  MyPantry
//
//  Created by Salvador on 7/16/24.
//

import SwiftUI

struct AddItemView: View {
    @State private var viewModel = AddItemViewModel()
    @State private var isDatePickerPresented = false
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
                    Section(header: Text("Details")) {
                        TextField("Name", text: $viewModel.name)
                            .focused($isNameFocused)

                        HStack {
                            Text("Quantity: \(viewModel.quantity)")
                                .font(.headline)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .onTapGesture {
                                    viewModel.isPickerVisible = true
                                }

                            Spacer()

                            Text("Clear")
                                .onTapGesture {
                                    viewModel.clearQuantity()
                                }
                                .foregroundColor(/*@START_MENU_TOKEN@*/ .blue/*@END_MENU_TOKEN@*/)
                        }

                        if viewModel.isPickerVisible {
                            Picker("Quantity", selection: $viewModel.quantity) {
                                ForEach(viewModel.range, id: \.self) { quantity in
                                    Text("\(quantity)")
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 150)
                            .onChange(of: viewModel.quantity) {
                                viewModel.isPickerVisible = false
                            }
                        }

                        Toggle("Favorite", isOn: $viewModel.isFavorite)
                        Toggle("Perishable?", isOn: $viewModel.hasExpirationDate)
                        if viewModel.hasExpirationDate {
                            DatePicker(
                                "Expiration Date",
                                selection: $viewModel.expirationDate,
                                displayedComponents: .date
                            )
                            .disabled(!viewModel.hasExpirationDate)
                            .foregroundColor(.red)
                        }
                    }

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
                    }) {
                        Text("Save")
                        Image(systemName: "checkmark")
                            .foregroundColor(/*@START_MENU_TOKEN@*/ .blue/*@END_MENU_TOKEN@*/)
                            .imageScale(.large)
                    }
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
