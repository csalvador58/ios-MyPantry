//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import Models
import SwiftUI

struct ListItemsView: View {
    @Bindable var viewModel: ListItemsViewModel
    @State private var showingAddItem = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.items) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        ItemRow(item: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("My Pantry")
            .toolbar {
                Button {
                    showingAddItem = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
            .overlay(Group {
                if viewModel.items.isEmpty {
                    Text("No items available")
                }
            })
        }
        .task {
            await viewModel.fetchItems()
            print("Items after fetch: \(viewModel.items.count)")
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        Task {
            for index in offsets {
                await viewModel.deleteItem(viewModel.items[index])
            }
        }
    }
}

struct ItemRow: View {
    let item: Item
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text("Quantity: \(item.quantity)")
                    .font(.subheadline)
            }
            Spacer()
            Text(item.status.descr)
                .font(.caption)
                .padding(5)
                .background(statusColor(for: item.status))
                .cornerRadius(5)
        }
    }
    
    private func statusColor(for status: ItemStatus) -> Color {
        switch status {
        case .inStock:
            return .green
        case .lowStock:
            return .yellow
        case .outOfStock:
            return .red
        case .inactive:
            return .gray
        }
    }
}

struct ItemDetailView: View {
    let item: Item
    
    var body: some View {
        // Implement the detail view here
        Text("Detail view for \(item.name)")
    }
}

//#Preview {
//    ListItemsView(viewModel: ItemListViewModel(privateItemManager: ItemManager(databaseType: .privateDB)))
//}

#Preview {
    ListItemsView(viewModel: MockListItemsViewModel())
}
