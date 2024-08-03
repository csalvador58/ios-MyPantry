//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import Models
import SwiftUI

@MainActor
struct InitialPantryView: View {
    @Environment(\.pantryService) private var pantryService
    @Bindable private var vm: PantryListViewModel
    @State private var showCreatePantrySheet = false
    @AppStorage("selectedPantryId") private var selectedPantryId: String?
    
    init(viewModel: PantryListViewModel? = nil) {
        _vm = Bindable(viewModel ?? PantryListViewModel(pantryService: PantryService(containerIdentifier: Config.containerIdentifier)))
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}


