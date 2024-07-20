//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import SwiftUI

struct AddItemDetailsView: View {
    @Bindable var viewModel: AddItemViewModel
    @FocusState.Binding var isNameFocused: Bool
    @State private var isDatePickerPresented = false
    
    var body: some View {
        Section(header: Text("Details")) {
            TextField("Name", text: $viewModel.name)
                .focused($isNameFocused)
            
            HStack {
                Text("Quantity: \(viewModel.quantity)")
                    .font(.headline)
                    .padding(8)
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
    }
}
