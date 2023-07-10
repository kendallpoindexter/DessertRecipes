import Foundation

@MainActor final class RecipeDetailsViewModel: ObservableObject {
    private let service = RecipesService()
    private let id: String
   
    @Published private var recipeDetails: RecipeDetails?
    
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
    
    init(id: String) {
        self.id = id
    }
    
    func getRecipeDetails() async {
        do {
            let detailsResponse = try await service.fetchRecipeDetails(with: id)
            recipeDetails = detailsResponse
        } catch {
            // Handle Error
        }
    }
}

