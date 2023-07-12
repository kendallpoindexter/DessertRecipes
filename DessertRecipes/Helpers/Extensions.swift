import Foundation

/// Checks if the HTTP response status code is in valid range.
///
/// - Returns: A Boolean indicating if the status code is between 200 and 299.
extension HTTPURLResponse {
    var isHttpResponseValid: Bool {
        (200...299).contains(self.statusCode)
    }
}
