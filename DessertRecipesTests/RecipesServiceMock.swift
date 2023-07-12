@testable import DessertRecipes
import Foundation

class RecipesServiceMock: RecipesServiceable {
    var mockFetchRecipesResult: Result<DessertRecipesResponse, NetworkErrors>?
    var mockFetchRecipeDetailsResult: Result<RecipeDetails, NetworkErrors>?
    
    func fetchRecipes() async throws -> DessertRecipes.DessertRecipesResponse {
        guard let mockFetchRecipesResult else {
            fatalError("If fetchRecipes is called we should have a mockFetchRecipesResult")
        }
        
        switch mockFetchRecipesResult {
        case let .success(recipesResponse):
            return recipesResponse
        case let .failure(error):
            throw error
        }
    }
    
    func fetchRecipeDetails(with id: String) async throws -> DessertRecipes.RecipeDetails {
        guard let mockFetchRecipeDetailsResult else {
            fatalError("If fetchRecipeDetails is called we should have a mockFetchRecipeDetailsResult")
        }
        
        switch mockFetchRecipeDetailsResult {
        case let .success(recipeDetails):
            return recipeDetails
        case let .failure(error):
            throw error
        }
    }
}
