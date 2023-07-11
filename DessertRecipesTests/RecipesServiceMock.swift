@testable import DessertRecipes
import Foundation

class RecipesServiceMock: RecipesServiceable {
    var recipesResponse: DessertRecipesResponse?
    var recipeDetails: RecipeDetails?
    var url: URL?
    var response: URLResponse?
    
    func fetchRecipes() async throws -> DessertRecipes.DessertRecipesResponse {
        guard let _ = url else {
            throw NetworkErrors.invalidURL
        }
        
        guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.isHttpResponseValid else {
            throw NetworkErrors.invalidHttpResponse
        }
        
        guard let recipesResponse = recipesResponse else {
            throw NetworkErrors.failedToDecode
        }
        
        return recipesResponse
    }
    
    func fetchRecipeDetails(with id: String) async throws -> DessertRecipes.RecipeDetails {
        guard let _ = url else {
            throw NetworkErrors.invalidURL
        }
        
        guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.isHttpResponseValid else {
            throw NetworkErrors.invalidHttpResponse
        }
        
        guard let recipeDetails = recipeDetails else {
            throw NetworkErrors.failedToDecode
        }
        
        return recipeDetails
    }
}
