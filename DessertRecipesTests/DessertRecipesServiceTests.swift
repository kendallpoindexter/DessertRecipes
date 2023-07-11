@testable import DessertRecipes
import XCTest

final class RecipesServiceTests: XCTestCase {
    
    func testFetchDessertRecipesResponseSuccessfully() async throws {
        // given
        let session = NetworkSessionMock()
        let url = URL(string: "google.com")!
        session.data = """
        {
          "meals": [
            {
              "strMeal": "Apam balik",
              "strMealThumb": "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg",
              "idMeal": "53049"
            }
                ]
            }
        """.data(using: .utf8)
        
        session.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let service = RecipesService(urlSession: session)
        
        
        // when
        let (mockData, _) = try await session.getData(from: url)
        let recipes = try await service.fetchRecipes()
        
        let decodedMockData = try JSONDecoder().decode(DessertRecipesResponse.self, from: mockData)
        
        //then
        XCTAssertEqual(decodedMockData, recipes)
    }
}
