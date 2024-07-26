//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import Models
import SwiftUI

struct EditableProperty: Identifiable {
    let id: String
    let name: String

    init(_ name: String) {
        self.id = name
        self.name = name
    }
}

struct EditPropertyView: View {
    @Binding var item: Item
    let property: String
    @Environment(\.dismiss) private var dismiss

    @State private var editedValue: String = ""
    @State private var editedDate: Date = .init()
    @State private var editedBool: Bool = false

    private func updateItem() {
        item = Item(
            id: item.id,
            name: property == "name" ? editedValue : item.name,
            quantity: property == "quantity" ? (Int(editedValue) ?? item.quantity) : item.quantity,
            quantityDesired: property == "quantityDesired" ? Int(editedValue) : item.quantityDesired,
            barcode: property == "barcode" ? (editedValue.isEmpty ? nil : editedValue) : item.barcode,
            favorite: property == "favorite" ? editedBool : item.favorite,
            customContent1: property == "customContent1" ? (editedValue.isEmpty ? nil : editedValue) : item.customContent1,
            customContent2: property == "customContent2" ? (editedValue.isEmpty ? nil : editedValue) : item.customContent2,
            customContent3: property == "customContent3" ? (editedValue.isEmpty ? nil : editedValue) : item.customContent3,
            dateAdded: property == "dateAdded" ? editedDate : item.dateAdded,
            dateLastUpdated: property == "dateLastUpdated" ? editedDate : item.dateLastUpdated,
            expireDate: property == "expireDate" ? editedDate : item.expireDate,
            note: property == "note" ? (editedValue.isEmpty ? nil : editedValue) : item.note,
            pantryId: item.pantryId,
            status: property == "status" ? (Item.ItemStatus(rawValue: Int(editedValue) ?? item.status.rawValue) ?? item.status) : item.status
        )
    }

    private var propertyGetters: [String: () -> Void] {
        [
            "name": { editedValue = item.name },
            "quantity": { editedValue = "\(item.quantity)" },
            "quantityDesired": { editedValue = item.quantityDesired.map { "\($0)" } ?? "" },
            "barcode": { editedValue = item.barcode ?? "" },
            "favorite": { editedBool = item.favorite },
            "customContent1": { editedValue = item.customContent1 ?? "" },
            "customContent2": { editedValue = item.customContent2 ?? "" },
            "customContent3": { editedValue = item.customContent3 ?? "" },
            "dateAdded": { editedDate = item.dateAdded },
            "dateLastUpdated": { editedDate = item.dateLastUpdated },
            "expireDate": { editedDate = item.expireDate ?? Date() },
            "note": { editedValue = item.note ?? "" },
            "status": { editedValue = String(item.status.rawValue) }
        ]
    }

    var body: some View {
        NavigationStack {
            Form {
                propertyEditView
            }
            .navigationTitle("Edit \(property.capitalized)")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveChanges() }
            )
            .onAppear { setupInitialValue() }
        }
    }

    private var propertyEditView: some View {
        Group {
            switch property {
            case "name", "barcode", "customContent1", "customContent2", "customContent3", "note":
                TextField("Enter new value", text: $editedValue)
            case "quantity", "quantityDesired":
                TextField("Enter new value", text: $editedValue)
                    .keyboardType(.numberPad)
            case "favorite":
                Toggle("Favorite", isOn: $editedBool)
            case "status":
                Picker("Status", selection: $editedValue) {
                    ForEach(Item.ItemStatus.allCases) { status in
                        Text(status.descr).tag(String(status.rawValue))
                    }
                }
            case "dateAdded", "dateLastUpdated", "expireDate":
                DatePicker("Select date", selection: $editedDate, displayedComponents: [.date])
            default:
                Text("Unsupported property")
            }
        }
    }

    private func setupInitialValue() {
        propertyGetters[property]?()
    }

    private func saveChanges() {
        updateItem()
        dismiss()
    }
}
