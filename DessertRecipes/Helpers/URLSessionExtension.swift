import Foundation

protocol NetworkSession {
    func getData(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {
    func getData(from url: URL) async throws -> (Data, URLResponse) {
        do {
            let (data, response) = try await Self.shared.data(from: url)
            return (data, response)
        } catch {
            throw NetworkErrors.failedToFetchData
        }
    }
}
