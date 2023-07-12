import Foundation

/// Response model containing a list of Recipe objects.
struct DessertRecipesResponse: Codable, Equatable {
    
    /// The list of Recipe objects returned in the response.
    let recipes: [Recipe]
    
    private enum CodingKeys: String, CodingKey {
        case recipes = "meals"
    }
}

/// Recipe model containing basic details of a recipe.
struct Recipe: Codable, Hashable, Identifiable {
    
    /// The name of the recipe.
    let name: String
    
    /// The URL string for the recipe's thumbnail image.
    let thumbnail: String
    
    /// The unique ID for the recipe.
    let id: String
    
    private enum CodingKeys: String, CodingKey {
        case name = "strMeal"
        case thumbnail = "strMealThumb"
        case id = "idMeal"
    }
}

/// Response model containing details for a single recipe.  
struct RecipeDetailsResponse: Codable {
    
    /// The RecipeDetails object containing the recipe details.
    let details: RecipeDetails
    
    /// Decodes the response containing an array of RecipeDetails. 
    /// and extracts the first object.
    /// - Throws: An error when if it fails to decode the first object in the array.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let detailsResponse = try container.decode([RecipeDetails].self, forKey: .details)
        
        guard let firstDetail = detailsResponse.first else {
            throw NetworkErrors.failedToDecode
        }
        
        self.details = firstDetail
    }
    
    private enum CodingKeys: String, CodingKey {
        case details = "meals"
    }
}

/// Model containing full recipe details.
struct RecipeDetails: Codable, Equatable {
    
    /// The recipe id.
    let id: String
    
    /// The list of recipe ingredients.
    let ingredients: [Ingredient]
    
    /// The instructions for the recipe.
    let instructions: String
    
    /// The recipe name.
    let name: String
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        
        init?(intValue: Int) {
            // We return nil here because our keys are strings
            return nil
        }
    }
    
    /// Initializes the recipe details with provided values.
    ///
    /// - Parameters:
    ///   - id: The recipe id.
    ///   - ingredients: The list of ingredients.
    ///   - instructions: The instructions.
    ///   - name: The recipe name.
    init(id: String, ingredients: [Ingredient], instructions: String, name: String) {
        self.id = id
        self.ingredients = ingredients
        self.instructions = instructions
        self.name = name
    }
    
    /// Decodes recipe details from the decoder by dynamically mapping keys.
    ///
    /// - Parameter decoder: The decoder to use.
    /// - Throws: Any decoding errors.
    init(from decoder: Decoder) throws {
        
        // Decode known keys
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        self.id = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: KnownKeys.id.rawValue)!)
        self.instructions = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue:KnownKeys.instructions.rawValue)!)
        self.name = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: KnownKeys.name.rawValue)!)
        
        // Decode ingredients and store them in a dictionary 
        var ingredientDictionary = [String: Ingredient.Builder]()
        
        for key in container.allKeys {
            
            // id represents the number found on the end of the strIngredient or strMeasure strings
            if key.stringValue.hasPrefix("strIngredient"), let id = Self.getIDFromIngredient(with: key.stringValue, type: .ingredientName) {
                let ingredientName = try? container.decode(String.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
                
                if let builder = ingredientDictionary[id] {
                    builder.setName(ingredientName)
                } else {
                    ingredientDictionary[id] = Ingredient.Builder(name: ingredientName)
                }
            } else if key.stringValue.hasPrefix("strMeasure"), let id = Self.getIDFromIngredient(with: key.stringValue, type: .measurement) {
                let measurement = try? container.decode(String.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
                if let builder = ingredientDictionary[id] {
                    builder.setMeasurement(measurement)
                } else {
                    ingredientDictionary[id] = Ingredient.Builder(measurement: measurement)
                }
            }
        }
        
        self.ingredients = ingredientDictionary.compactMap { $0.value.build() }
    }
    
    /// Known coding keys.
    private enum KnownKeys: String {
        case id = "idMeal"
        case instructions = "strInstructions"
        case name = "strMeal"
    }
    
    /// Ingredient component types.
    private enum IngredientComponentType {
        case ingredientName
        case measurement
    }
    
    /// Gets the ingredient id from the dynamic key.
    /// The id represents the number found at the end of a measurement or ingredient name string.
    /// - Parameters:
    ///   - key: The dynamic key string.
    ///   - type: The component type.
    /// - Returns: The ingredient ID if found.
    private static func getIDFromIngredient(with key: String, type: IngredientComponentType) -> String? {
        var ingredientRegex: Regex<(Substring, Substring)>?
        
        switch type {
        case .ingredientName:
            ingredientRegex = /^strIngredient(\d+)$/
        case .measurement:
            ingredientRegex = /^strMeasure(\d+)$/
        }
        
        if let ingredientRegex = ingredientRegex, let match = key.firstMatch(of: ingredientRegex) {
            return String(match.output.1)
        } else {
            return nil
        }
    }
}

/// Model containing the name and measurement for an ingredient.
struct Ingredient: Codable, Equatable, Identifiable {
    
    /// The unique ID.
    let id: UUID
    
    /// The ingredient name.
    let name: String
    
    /// The measurement amount and unit.
    let measurement: String
    
    /// Builder class to construct Ingredient instances.
    final class Builder {
        
        /// Optional ingredient name.
        private(set) var name: String?
        
        /// Optional measurement amount.
        private(set) var measurement: String?
        
        
        /// Creates a new builder instance.
        ///
        /// - Parameters:
        ///   - name: Optional initial name value.
        ///   - measurement: Optional initial measurement value.
        init(name: String? = nil, measurement: String? = nil) {
            self.name = name
            self.measurement = measurement
        }
        
        /// Sets the name value.
        ///
        /// - Parameter name: The name to set.
        func setName(_ name: String?) {
            self.name = name
        }
        
        /// Sets the measurement value.
        ///
        /// - Parameter measurement: The measurement to set.
        func setMeasurement(_ measurement: String?) {
            self.measurement = measurement
        }
        
        /// Attempts to build and return an Ingredient instance.
        ///
        /// - Returns: An Ingredient if valid, otherwise returns nil.
        func build() -> Ingredient? {
            guard let name = name,
                  name.trimmingCharacters(in: .whitespacesAndNewlines) != "",
                  let measurement = measurement,
                  measurement.trimmingCharacters(in: .whitespacesAndNewlines) != ""
            else {
                return nil
            }
            
            return Ingredient(id: UUID(), name: name, measurement: measurement)
        }
    }
}
