@testable import DessertRecipes
import XCTest

final class RecipeDetailsViewModelTests: XCTestCase {
    let service = RecipesServiceMock()
    
    func testGetRecipeDetailsUpdatesRecipeDetailsStateAndViewState() async throws {
        let expectedRecipeDetails = RecipeDetails(area: "", id: "", ingredients: [], instructions: "", name: "Test", youtubeURLString: "")
        let expectedRecipe = Recipe(name: "", thumbnail: "", id: "")
        
        let viewModel = await RecipeDetailsViewModel(recipe: expectedRecipe, service: service)
        let intialViewState = await viewModel.viewState
        
        service.mockFetchRecipeDetailsResult = .success(expectedRecipeDetails)

        XCTAssertEqual(intialViewState, .idle)
        
        await viewModel.getRecipeDetails()
        
        let imageURLString = await viewModel.imageURLString
        let ingredients = await viewModel.ingredients
        let instructions = await viewModel.instructions
        let recipeName = await viewModel.name
        
        let viewStateAfterNetworkCallFinishes = await viewModel.viewState
        
        XCTAssertEqual(expectedRecipe.thumbnail, imageURLString)
        XCTAssertEqual(expectedRecipeDetails.ingredients, ingredients )
        XCTAssertEqual(expectedRecipeDetails.instructions, instructions )
        XCTAssertEqual(expectedRecipeDetails.name, recipeName)
        XCTAssertEqual(viewStateAfterNetworkCallFinishes, .loaded)
    }
    
    func testGetRecipeDetailsUpdatesViewStateUponFailure() async throws {
        let expectedRecipe = Recipe(name: "", thumbnail: "", id: "")
        
        let viewModel = await RecipeDetailsViewModel(recipe: expectedRecipe, service: service)
        let intialViewState = await viewModel.viewState
        
        service.mockFetchRecipeDetailsResult = .failure(NetworkErrors.failedToDecode)
        
        XCTAssertEqual(intialViewState, .idle)
        
        await viewModel.getRecipeDetails()
        
        let viewStateAfterNetworkCallFinishes = await viewModel.viewState
        
        XCTAssertEqual(viewStateAfterNetworkCallFinishes, .error)
    }
}
