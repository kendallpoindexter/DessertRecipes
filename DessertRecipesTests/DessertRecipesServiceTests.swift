@testable import DessertRecipes
import XCTest

final class RecipesServiceTests: XCTestCase {
    let session = NetworkSessionMock()
    
    func testFetchRecipesReturnsRecipesUponSuccess() async throws {
        let service = RecipesService(urlSession: session)
        let expectedRecipes = [Recipe(name: "Test", thumbnail: "", id: "12345")]
        let data = """
          {
            "meals": [
              {
                "strMeal": "Test",
                "strMealThumb": "",
                "idMeal": "12345",
              }
                  ]
              }
          """.data(using: .utf8)
        let response = HTTPURLResponse(url: URL(string: "www.google.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        session.mockResult = (data!, response)
    
        let recipesResponse = try await service.fetchRecipes()
        
        XCTAssertEqual(expectedRecipes, recipesResponse.recipes)
    }
    
    func testFetchRecipesResponseFailsWithInvalidURL() async throws {
        let service = RecipesService(urlSession: session)
        let data = """
          {
            "meals": [
              {
                "strMeal": "Test",
                "strMealThumb": "",
                "idMeal": "12345",
              }
                  ]
              }
          """.data(using: .utf8)
        
        let response = HTTPURLResponse(url: URL(string: "www..com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        session.mockResult = (data!, response)
        
        do {
            let _ = try await service.fetchRecipes()
        } catch {
            XCTAssertEqual(error as! NetworkErrors, NetworkErrors.invalidURL)
        }
    }
    
    func testFetchRecipesResponseFailsWithInvalidResponseCode() async throws {
        let service = RecipesService(urlSession: session)
        let data = """
          {
            "meals": [
              {
                "strMeal": "Test",
                "strMealThumb": "",
                "idMeal": "12345",
              }
                  ]
              }
          """.data(using: .utf8)
        
        let response = HTTPURLResponse(url: URL(string: "www.google.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
        
        session.mockResult = (data!, response)
        
        do {
            let _ = try await service.fetchRecipes()
        } catch {
            XCTAssertEqual(error as! NetworkErrors, NetworkErrors.invalidHttpResponse)
        }
    }
    
    func testFetchRecipesResponseFailsWithInvalidData() async throws {
        let service = RecipesService(urlSession: session)
        let data = """
          {
            "meals": [
              {
                "strMeal": "Apam balik",
                "strMealThumb": "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg",
                "idMeal": "53049",
                "testKey": "causes failure"
              }
                  ]
              }
          """.data(using: .utf8)
        
        let response = HTTPURLResponse(url: URL(string: "www..com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        session.mockResult = (data!, response)
        
        do {
            let _ = try await service.fetchRecipes()
        } catch {
            XCTAssertEqual(error as! NetworkErrors, NetworkErrors.invalidURL)
        }
    }
    
    func testFetchRecipeDetailsReturnsRecipeDetailsUponSuccess() async throws {
        let service = RecipesService(urlSession: session)
        let expectedRecipeDetails = RecipeDetails(area: "", id: "", ingredients: [], instructions: "", name: "Test", youtubeURLString: "")
        let data = """
        {
          "meals": [
            {
              "idMeal": "",
              "strMeal": "Test",
              "strArea": "",
              "strInstructions": "",
              "strYoutube": "",
              "ingredients": [
                    {
                        }
                ]
            }
          ]
        }
        """.data(using: .utf8)
        
        let response = HTTPURLResponse(url: URL(string: "www.google.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        session.mockResult = (data!, response)
        
        let recipeDetailsResponse = try await service.fetchRecipeDetails(with: "12345")
        
        XCTAssertEqual(expectedRecipeDetails, recipeDetailsResponse)
    }
    
    func testFetchRecipeDetailsFailsWithInvalidURL() async throws {
        let service = RecipesService(urlSession: session)
        let data = """
        {
          "meals": [
            {
              "idMeal": "",
              "strMeal": "Test",
              "strArea": "",
              "strInstructions": "",
              "strYoutube": "",
              "ingredients": [
                    {
                        }
                ]
            }
          ]
        }
        """.data(using: .utf8)
        let response = HTTPURLResponse(url: URL(string: "www..com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        session.mockResult = (data!, response)
        
        do {
            let _ = try await service.fetchRecipeDetails(with: "")
        } catch {
            XCTAssertEqual(error as! NetworkErrors, NetworkErrors.invalidURL)
        }
    }
    
    func testFetchRecipeDetailsFailsWithInvalidResponseCode() async throws {
        let service = RecipesService(urlSession: session)
        let data = """
        {
          "meals": [
            {
              "idMeal": "",
              "strMeal": "Test",
              "strArea": "",
              "strInstructions": "",
              "strYoutube": "",
              "ingredients": [
                    {
                        }
                ]
            }
          ]
        }
        """.data(using: .utf8)
        
        let response = HTTPURLResponse(url: URL(string: "www.google.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
        
        session.mockResult = (data!, response)
        
        do {
            let _ = try await service.fetchRecipeDetails(with: "")
        } catch {
            XCTAssertEqual(error as! NetworkErrors, NetworkErrors.invalidHttpResponse)
        }
    }
    
    func testFetchRecipeDetailsFailsWithInvalidData() async throws {
        let service = RecipesService(urlSession: session)
        let data = """
        {
          "meals": [
            {
              "testkey": ""
              "idMeal": "",
              "strMeal": "Test",
              "strArea": "",
              "strInstructions": "",
              "strYoutube": "",
              "ingredients": [
                    {
                        }
                ]
            }
          ]
        }
        """.data(using: .utf8)
        
        let response = HTTPURLResponse(url: URL(string: "www.google.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        session.mockResult = (data!, response)
        
        do {
            let _ = try await service.fetchRecipeDetails(with: "")
        } catch {
            XCTAssertEqual(error as! NetworkErrors, NetworkErrors.failedToDecode)
        }
    }
    
}
