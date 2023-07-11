@testable import DessertRecipes
import Foundation

class NetworkSessionMock: NetworkSession {
    var data: Data?
    var response: URLResponse?
    
    func getData(from url: URL) async throws -> (Data, URLResponse) {
        guard let data = data, let response = response else {
            throw NetworkErrors.failedToFetchData
        }
        return (data, response)
    }
}
