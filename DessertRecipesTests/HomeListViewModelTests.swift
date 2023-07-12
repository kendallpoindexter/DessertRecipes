@testable import DessertRecipes
import XCTest

final class HomeListViewModelTests: XCTestCase {
    let service = RecipesServiceMock()
    
    func testGetRecipesUpdatesRecipeStateAndViewState() async throws {
        let expectedRecipes = [Recipe(name: "Test", thumbnail: "", id: "12345")]
        let dessertRecipesResponse = DessertRecipesResponse(recipes: expectedRecipes)
        let viewModel = await HomeListViewModel(service: service)
        let intialViewState = await viewModel.viewState
        
        service.mockFetchRecipesResult = .success(dessertRecipesResponse)
        
        XCTAssertEqual(intialViewState, .idle)
        
        await viewModel.getRecipes()
        
        let recipes = await viewModel.recipes
        let viewStateAfterNetworkCallFinishes = await viewModel.viewState
        
        XCTAssertEqual(expectedRecipes, recipes)
        XCTAssertEqual(viewStateAfterNetworkCallFinishes, .loaded)
    }
    
    func testGetRecipesUpdatesViewStateUponFailure() async throws {
        let viewModel = await HomeListViewModel(service: service)
        let intialViewState = await viewModel.viewState
        
        service.mockFetchRecipesResult = .failure(NetworkErrors.failedToDecode)
        
        XCTAssertEqual(intialViewState, .idle)
        
        await viewModel.getRecipes()
        
        let viewState = await viewModel.viewState
        
        XCTAssertEqual(viewState, .error )
    }
}
