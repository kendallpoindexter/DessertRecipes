import NukeUI
import SwiftUI

/// Recipe detail view.
struct RecipeDetailView: View {
    
    /// View model for handling state and data.
    @StateObject var viewModel: RecipeDetailsViewModel
    
    /// Recipe service for fetching data.
    let service = RecipesService()
    
    /// Body view displaying UI based on view model state:
    ///
    /// - .idle, .loading: Show ProgressView
    ///
    /// - .loaded: Show scrollable view with:
    ///   - Use LazyImage to load recipe image 
    ///   - Display recipe instructions 
    ///   - Display ingredients list
    ///
    /// - .error: Show error text and retry button
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .idle, .loading:
                ProgressView()
            case .loaded:
                ScrollView {
                    VStack(alignment: .leading) {
                        LazyImage(url: URL(string: viewModel.imageURLString)) { state in
                            if let image = state.image {
                                image.resizable().aspectRatio(contentMode: .fit)
                            }
                        }
                        Spacer()
                        Text("Instructions")
                            .font(.title)
                            .bold()
                        Spacer()
                        Text(viewModel.instructions)
                        Spacer()
                        Text("Ingredients")
                            .font(.title)
                            .bold()
                        Spacer()
                        ForEach(viewModel.ingredients) { ingredient in
                            Text(ingredient.measurement + " " + ingredient.name)
                            Divider()
                        }
                    }
                    .padding()
                }
            case .error:
                Text("Oops! Couldn't find this recipe. Please try again.")
                    .padding()
                Button("Retry") {
                    Task {
                        await viewModel.getRecipeDetails()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        
        /// Fetches recipe details when view appears. 
        .task {
            await viewModel.getRecipeDetails()
        }
        
        /// Navigation title and styling
        .navigationTitle(viewModel.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = RecipeDetailsViewModel(recipe: (Recipe(name: "Test", thumbnail: "", id: "52900")))
        
        NavigationStack {
            RecipeDetailView(viewModel: viewModel)
        }
    }
}
