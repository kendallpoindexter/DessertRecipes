import NukeUI
import SwiftUI

/// Home list view showing dessert recipes.
struct HomeListView: View {
    
    /// View model for handling state and data.
    @StateObject private var viewModel = HomeListViewModel()
    
    /// Recipe service for fetching data.
    private let service = RecipesService()
    
    /// Body view displaying UI based on view model state:
    ///
    /// - .idle, .loading: Show ProgressView 
    ///
    /// - .loaded: Show list of recipes with navigation links:
    ///   - Use LazyImage to load thumbnail 
    ///   - Display recipe name
    ///   
    /// - .error: Show error text and retry button
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .idle, .loading:
                ProgressView()
            case .loaded:
                List(viewModel.recipes) { recipe in
                    NavigationLink(value: recipe) {
                        HStack {
                            LazyImage(url: URL(string: recipe.thumbnail)) { state in
                                if let image = state.image {
                                    image.resizable().scaledToFit().frame(width: 50, height: 50)
                                }
                            }
                            Text(recipe.name)
                        }
                    }
                }
            case .error:
                Text("Oops! Looking for recipes? Please try again.")
                    .padding()
                Button("Retry") {
                    Task {
                        await viewModel.getRecipes()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        
        /// Fetches recipes when view appears.
        .task {
            await viewModel.getRecipes()
        }
        
        /// Navigation to recipe detail view.
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(viewModel: RecipeDetailsViewModel(recipe: recipe))
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
