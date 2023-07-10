//
//  ContentView.swift
//  DessertRecipes
//
//  Created by Kendall Poindexter on 7/8/23.
//

import SwiftUI

struct HomeListView: View {
    @StateObject private var viewModel = HomeListViewModel()
    let service = RecipesService()
    
    var body: some View {
        List(viewModel.recipes) { recipe in
            NavigationLink(recipe.name, value: recipe.id)
        }
        .task {
             await viewModel.getRecipes()
        }
        .navigationTitle("Desserts")
        .navigationDestination(for: String.self) { id in
            RecipeDetailView(viewModel: RecipeDetailsViewModel(id: id))
        }
    }
}

struct HomeListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListView()
    }
}
