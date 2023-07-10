import Foundation

extension HTTPURLResponse {
    var isHttpResponseValid: Bool {
        (200...299).contains(self.statusCode)
    }
}
