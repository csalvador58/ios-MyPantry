//
//  AddItemView.swift
//  MyPantry
//
//  Created by Salvador on 7/16/24.
//

import SwiftUI

struct AddItemView: View {
    @State private var name: String = ""
    @State private var barcode: String = ""
    @State private var isFavorite: Bool = false
    @State private var expirationDate: Date = Date()
    @State private var notes: String = ""
    @State private var hasExpirationDate: Bool = false
    @State private var searchText: String = ""
    @State private var searchResults: [String] = ["Apple", "Banana", "Orange", "Grapes", "Mango"]
    @FocusState private var isSearchFocused: Bool
    @FocusState private var isNameFocused: Bool
    
    var filteredResults: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return searchResults.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(filteredResults, id: \.self) { result in
                        Text(result)
                            .onTapGesture {
                                name = result
                                searchText = ""
                                isNameFocused = true
                            }
                    }
                }
                .listStyle(.plain)
                .frame(height: filteredResults.isEmpty ? 0 : nil)
                
                Form {
                    Section(header: Text("Details")) {
                        TextField("Name", text: $name)
                            .focused($isNameFocused)
                        
                        TextField("Barcode", text: $barcode)
                            .keyboardType(.numberPad)
                        
                        Toggle("Favorite", isOn: $isFavorite)
                        
                        Toggle("Has Expiration Date", isOn: $hasExpirationDate)
                        
                        DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                            .disabled(!hasExpirationDate)
                            .foregroundColor(hasExpirationDate ? .primary : .secondary)
                    }
                    
                    Section(header: Text("Item Notes")) {
                        TextEditor(text: $notes)
                            .frame(height: 100)
                    }
                }
            }
            .navigationTitle("Add Pantry Item")
            .navigationBarItems(trailing: Button(action: {
                saveItem()
            }) {
                Text("Save")
                    .padding(.trailing, -10)
                Image(systemName: "checkmark")
                    .foregroundColor(Color(.blue))
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
            })
            .searchable(text: $searchText, prompt: "Search for items")
            .focused($isSearchFocused)
        }
    }
    
    private func saveItem() {
        // Implementation for saving the item
    }
    
    private func resetSearch() {
        
    }
}



#Preview {
    AddItemView()
}
