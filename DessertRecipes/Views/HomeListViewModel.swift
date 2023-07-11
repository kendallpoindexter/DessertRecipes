import Foundation

@MainActor final class HomeListViewModel: ObservableObject {
    @Published private(set) var recipes = [Recipe]()
    @Published private(set) var viewState = ViewState.idle
    private let service = RecipesService()
    
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
