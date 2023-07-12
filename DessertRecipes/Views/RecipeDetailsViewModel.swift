import Foundation

@MainActor final class RecipeDetailsViewModel: ObservableObject {
    @Published private var recipeDetails: RecipeDetails?
    @Published private(set) var viewState = ViewState.idle
    private let recipe: Recipe
    private let service: RecipesServiceable
    
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
    
    init(recipe: Recipe, service: RecipesServiceable = RecipesService()) {
        self.recipe = recipe
        self.service = service
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

