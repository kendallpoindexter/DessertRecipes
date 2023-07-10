import Foundation

@MainActor final class HomeListViewModel: ObservableObject {
    @Published private(set) var recipes = [Recipe]()
    private let service = RecipesService()
    
    func getRecipes() async {
        do {
            let recipesResponse = try await service.fetchRecipes()
            recipes = recipesResponse.recipes
        } catch {
            recipes = []
        }
    }
}
