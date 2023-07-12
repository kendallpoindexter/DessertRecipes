import NukeUI
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
        .task {
             await viewModel.getRecipes()
        }
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
