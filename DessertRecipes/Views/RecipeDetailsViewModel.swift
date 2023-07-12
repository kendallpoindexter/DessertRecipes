import Foundation

@MainActor final class RecipeDetailsViewModel: ObservableObject {
    private let service = RecipesService()
    private let recipe: Recipe
   
    @Published private var recipeDetails: RecipeDetails?
    @Published private(set) var viewState = ViewState.idle
    
    //Make sure to better handle these optional values and error handling
    var imageURLString: String {
        recipe.thumbnail
    }
    var ingredients: [Ingredient] {
        guard let ingredients = recipeDetails?.ingredients else { return [] }
        return ingredients.sorted { $0.name < $1.name }
    }
    
    var instructions: String {
        return recipeDetails?.instructions ?? ""
    }
    
    var name: String {
        return recipeDetails?.name ?? ""
    }
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
    
    func getRecipeDetails() async {
        viewState = .loading
        
        do {
            let detailsResponse = try await service.fetchRecipeDetails(with: recipe.id)
            recipeDetails = detailsResponse
            viewState = .loaded
        } catch {
            viewState = .error
        }
    }
}

