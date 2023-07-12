import Foundation

/// View model for the home list screen.
@MainActor final class HomeListViewModel: ObservableObject {
    
    /// Published recipes list.
    @Published private(set) var recipes = [Recipe]()
    
    /// Published view state.
    @Published private(set) var viewState = ViewState.idle
    
    /// Recipe service for fetching data.
    private let service: RecipesServiceable
    
    /// Initializes the view model with the recipe service.
    ///
    /// - Parameter service: The recipe service.
    init(service: RecipesServiceable = RecipesService()) {
        self.service = service
    }
    
    /// Fetches recipes from the service and updates view state.
    func getRecipes() async {
        viewState = .loading
        do {
            let recipesResponse = try await service.fetchRecipes()
            recipes = recipesResponse.recipes
            viewState = .loaded
        } catch {
            viewState = .error
        }
    }
}
