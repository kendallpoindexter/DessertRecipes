import Foundation

@MainActor final class RecipeDetailsViewModel: ObservableObject {
    @Published private var recipeDetails: RecipeDetails?
    @Published private(set) var viewState = ViewState.idle
    private let id: String
    private let service: RecipesServiceable
    
    //Make sure to better handle these optional values and error handling
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
    
    init(id: String, service: RecipesServiceable = RecipesService()) {
        self.id = id
        self.service = service
    }
    
    func getRecipeDetails() async {
        viewState = .loading
        
        do {
            let detailsResponse = try await service.fetchRecipeDetails(with: id)
            recipeDetails = detailsResponse
            viewState = .loaded
        } catch {
            viewState = .error
        }
    }
}

