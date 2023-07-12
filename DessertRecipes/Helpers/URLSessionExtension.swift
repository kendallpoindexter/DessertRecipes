import Foundation

/// Protocol that defines the `getData(from:)` method for retrieving data from a URL.
protocol NetworkSession {
    /// Fetches data asynchronously from the provided URL and returns the data and response.
    ///
    /// - Parameter url: The URL to fetch data from.
    /// - Returns: A tuple containing the data and response from the URL.
    /// - Throws: Any error that occurs during the request.
    func getData(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {
    /// Fetches data asynchronously from the provided URL using the shared `URLSession` 
    /// instance and returns the data and response.
    ///
    /// - Parameter url: The URL to fetch data from.
    /// - Returns: A tuple containing the data and response from the URL.
    /// - Throws: Any error that occurs during the request.
    func getData(from url: URL) async throws -> (Data, URLResponse) {
        let (data, response) = try await Self.shared.data(from: url)
        return (data, response)
    }
}
