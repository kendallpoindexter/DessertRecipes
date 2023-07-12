@testable import DessertRecipes
import Foundation

class NetworkSessionMock: NetworkSession {
    var mockResult: (Data, URLResponse)?
    
    func getData(from url: URL) async throws -> (Data, URLResponse) {
        guard let mockResult else {
             fatalError("getData was called but mock result was nil")
        }
        return mockResult
    }
}
