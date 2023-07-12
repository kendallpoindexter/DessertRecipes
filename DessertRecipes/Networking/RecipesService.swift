import Foundation

/// Enum representing possible network errors.
enum NetworkErrors: Error {
    /// Error thrown when decoding a response fails.
    case failedToDecode
    
    /// Error thrown when HTTP response is invalid.
    case invalidHttpResponse
    
    /// Error thrown when constructed URL is invalid.
    case invalidURL
}

/// Protocol for recipe service to fetch recipes and recipe details.
protocol RecipesServiceable {
    /// Fetches a list of dessert recipes.
    ///
    /// - Returns: The dessert recipes response.  
    /// - Throws: Possible network errors.
    func fetchRecipes() async throws -> DessertRecipesResponse
    
    /// Fetches the details for a recipe by id.
    /// 
    /// - Parameter id: The recipe ID.
    /// - Returns: The recipe details.
    /// - Throws: Possible network errors.
    func fetchRecipeDetails(with id: String) async throws -> RecipeDetails
}

/// Concrete implementation of RecipesServiceable protocol.
struct RecipesService: RecipesServiceable {
    let urlSession: NetworkSession
    
    
    init(urlSession: NetworkSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    /// Fetches a list of dessert recipes.
    ///
    /// - Returns: The dessert recipes response.
    /// - Throws: Possible network errors.
    func fetchRecipes() async throws -> DessertRecipesResponse {
        guard let url = constructURL(with: .recipes, query: "Dessert") else {
            throw NetworkErrors.invalidURL
        }
        
        let recipesResponse = try await fetchValue(from: url, with: DessertRecipesResponse.self)
        
        return recipesResponse
    }
    
    /// Fetches the details for a recipe by id.
    ///
    /// - Parameter id: The recipe id.
    /// - Returns: The recipe details. 
    /// - Throws: Possible network errors.
    func fetchRecipeDetails(with id: String) async throws -> RecipeDetails {
        guard let url = constructURL(with: .lookupRecipeDetails, query: id) else {
            throw NetworkErrors.invalidURL
        }
        
        let recipeDetailsResponse = try await fetchValue(from: url, with: RecipeDetailsResponse.self)
        
        return recipeDetailsResponse.details
    }
    
    /// Fetches and decodes a value from the given URL.
    ///
    /// - Parameters:
    ///   - url: The URL to fetch from.
    ///   - type: The type to decode to.
    /// - Returns: The decoded value.
    /// - Throws: Possible network errors.
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
    
    /// Constructs a URL for the given path and query.
    ///
    /// - Parameters:
    ///   - path: The API path to use.
    ///   - query: An optional query string.
    /// - Returns: The constructed URL.
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
    
    /// API paths.
    enum Paths: String {
        case recipes = "filter"
        case lookupRecipeDetails = "lookup"
    }
}
