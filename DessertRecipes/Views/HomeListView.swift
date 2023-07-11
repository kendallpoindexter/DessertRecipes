import SwiftUI

struct HomeListView: View {
    @StateObject private var viewModel = HomeListViewModel()
    private let service = RecipesService()
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .idle, .loading:
                ProgressView()
            case .loaded:
                List(viewModel.recipes) { recipe in
                    NavigationLink(recipe.name, value: recipe.id)
                }
            case .error:
                Text("Empty table view state")
            }
        }
        .task {
             await viewModel.getRecipes()
        }
        .navigationDestination(for: String.self) { id in
            RecipeDetailView(viewModel: RecipeDetailsViewModel(id: id))
        }
        .navigationTitle("Desserts")
    }
}


struct HomeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeListView()
        }
    }
}
