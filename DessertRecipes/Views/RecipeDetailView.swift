
import SwiftUI

struct RecipeDetailView: View {
   // let id: String
    @StateObject var viewModel: RecipeDetailsViewModel
    let service = RecipesService()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
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
        .task {
            await viewModel.getRecipeDetails()
        }
        .navigationTitle(viewModel.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = RecipeDetailsViewModel(id: "52900")
        RecipeDetailView(viewModel: viewModel)
    }
}
