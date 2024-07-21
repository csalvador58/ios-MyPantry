//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import Models
import SwiftUI

struct ListItemsView: View {
    @State var viewModel = ListItemsViewModel()
    @State var showingAddItem: Bool = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.items, id: \.self) { item in
                    NavigationLink(value: item) {
                        ItemRow(item: item)
                    }
                }
            }
            .navigationTitle("My Pantry")
            .overlay(Group {
                if viewModel.items.isEmpty {
                    Text("No items available")
                }
            })
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
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
            }
        }
        .task {
            await viewModel.fetchItems(by: "1234")
        }
    }
}

#Preview {
    ListItemsView(viewModel: MockListItemsViewModel())
}
