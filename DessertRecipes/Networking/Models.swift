import Foundation

struct DessertRecipesResponse: Codable, Equatable {
    let recipes: [Recipe]
    
    enum CodingKeys: String, CodingKey {
        case recipes = "meals"
    }
}

struct Recipe: Codable, Hashable, Identifiable {
    let name: String
    let thumbnail: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case name = "strMeal"
        case thumbnail = "strMealThumb"
        case id = "idMeal"
    }
}

struct RecipeDetailsResponse: Codable {
    let details: RecipeDetails
    
    init(details: RecipeDetails) {
        self.details = details
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let detailsResponse = try container.decode([RecipeDetails].self, forKey: .details)
        
        guard let firstDetail = detailsResponse.first else {
            throw NetworkErrors.failedToDecode
        }
        
        self.details = firstDetail
    }
    
    enum CodingKeys: String, CodingKey {
        case details = "meals"
    }
}

struct RecipeDetails: Codable, Equatable {
    let area: String
    let id: String
    let ingredients: [Ingredient]
    let instructions: String
    let name: String
    let youtubeURLString: String
    
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
    
    init(area: String, id: String, ingredients: [Ingredient], instructions: String, name: String, youtubeURLString: String) {
        self.area = area
        self.id = id
        self.ingredients = ingredients
        self.instructions = instructions
        self.name = name
        self.youtubeURLString = youtubeURLString
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        self.area = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: KnownKeys.area.rawValue)!)
        self.id = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: KnownKeys.id.rawValue)!)
        self.instructions = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue:KnownKeys.instructions.rawValue)!)
        self.name = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: KnownKeys.name.rawValue)!)
        self.youtubeURLString = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: KnownKeys.youtubeURLString.rawValue)!)
        
        var ingredientDictionary = [String: Ingredient.Builder]()
        
        for key in container.allKeys {
            
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
    
    enum KnownKeys: String {
        case area = "strArea"
        case id = "idMeal"
        case instructions = "strInstructions"
        case name = "strMeal"
        case youtubeURLString = "strYoutube"
    }
    
    private enum IngredientComponentType {
        case ingredientName
        case measurement
    }
    
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

struct Ingredient: Codable, Equatable, Identifiable {
    let id: UUID
    let name: String
    let measurement: String
    
    final class Builder {
        private(set) var name: String?
        private(set) var measurement: String?
        
        init(name: String? = nil, measurement: String? = nil) {
            self.name = name
            self.measurement = measurement
        }
        
        func setName(_ name: String?) {
            self.name = name
        }
        
        func setMeasurement(_ measurement: String?) {
            self.measurement = measurement
        }
        
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
