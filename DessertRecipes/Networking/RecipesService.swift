import Foundation

enum NetworkErrors: Error {
    case failedToDecode
    case invalidHttpResponse
    case invalidURL
}

protocol RecipesServiceable {
    func fetchRecipes() async throws -> DessertRecipesResponse
    func fetchRecipeDetails(with id: String) async throws -> RecipeDetails
}

struct RecipesService: RecipesServiceable {
    let urlSession: NetworkSession
    
    init(urlSession: NetworkSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func fetchRecipes() async throws -> DessertRecipesResponse {
        guard let url = constructURL(with: .recipes, query: "Dessert") else {
            throw NetworkErrors.invalidURL
        }
        
        let recipesResponse = try await fetchValue(from: url, with: DessertRecipesResponse.self)
        
        return recipesResponse
    }
    
    func fetchRecipeDetails(with id: String) async throws -> RecipeDetails {
        guard let url = constructURL(with: .lookupRecipeDetails, query: id) else {
            throw NetworkErrors.invalidURL
        }
        
        let recipeDetailsResponse = try await fetchValue(from: url, with: RecipeDetailsResponse.self)
        
        return recipeDetailsResponse.details
    }
    
    private func fetchValue<T: Decodable>(from url: URL, with type: T.Type) async throws -> T {
        let (data, response) = try await urlSession.getData(from: url)
        
        guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.isHttpResponseValid else {
            throw NetworkErrors.invalidHttpResponse
        }
        
        guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
            throw NetworkErrors.failedToDecode
        }
        
        return decodedData
    }
    
    private func constructURL(with path: Paths, query: String?) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.themealdb.com"
        components.path = "/api/json/v1/1/\(path.rawValue).php"
        
        switch path {
        case .recipes:
            components.queryItems = [
                URLQueryItem(name: "c", value: query)
            ]
        case .lookupRecipeDetails:
            components.queryItems = [
                URLQueryItem(name: "i", value: query)
            ]
        }
        
        return components.url
    }
    
    enum Paths: String {
        case recipes = "filter"
        case lookupRecipeDetails = "lookup"
    }
}
