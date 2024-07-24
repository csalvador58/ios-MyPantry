//
//  ItemDetailView.swift
//  MyPantry
//
//  Created by Salvador on 7/20/24.
//
import Models
import SwiftUI

struct ItemDetailView: View {
    @State var item: Item
    var body: some View {
        Text("Detail View for: \(item.name)")
    }
}

#Preview {
    Group {
        let mockViewModel = MockListItemsViewModel()
        let item = mockViewModel.items.first
        ItemDetailView(item: item!)
    }
}
