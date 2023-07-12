import NukeUI
import SwiftUI

struct RecipeDetailView: View {
    @StateObject var viewModel: RecipeDetailsViewModel
    let service = RecipesService()
    
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
        .task {
            await viewModel.getRecipeDetails()
        }
        .navigationTitle(viewModel.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = RecipeDetailsViewModel(recipe: (Recipe(name: "Test", thumbnail: "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg", id: "52900")))
        RecipeDetailView(viewModel: viewModel)
    }
}
