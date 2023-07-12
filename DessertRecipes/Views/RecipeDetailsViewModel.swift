import Foundation

/// View model for recipe details screen.
@MainActor final class RecipeDetailsViewModel: ObservableObject {
    
    /// Published recipe details.
    @Published private var recipeDetails: RecipeDetails?
    
    /// Published view state.
    @Published private(set) var viewState = ViewState.idle
    
    /// Recipe to fetch details for.
    private let recipe: Recipe
    
    /// Recipe service for fetching data.
    private let service: RecipesServiceable
    
    /// Recipe thumbnail image URL string.
    var imageURLString: String {
        recipe.thumbnail
    }
    
    /// Sorted list of recipe ingredients.
    var ingredients: [Ingredient] {
        guard let ingredients = recipeDetails?.ingredients else { return [] }
        return ingredients.sorted { $0.name < $1.name }
    }
    
    /// Recipe instructions.
    var instructions: String {
        return recipeDetails?.instructions ?? ""
    }
    
    /// Recipe name.
    var name: String {
        return recipeDetails?.name ?? ""
    }
    
    /// Initializes the view model with a recipe and service.
    ///
    /// - Parameters:
    ///   - recipe: The recipe to fetch details for.
    ///   - service: The recipe service.
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

