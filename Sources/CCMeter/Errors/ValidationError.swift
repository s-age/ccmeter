import Foundation

enum ValidationError: LocalizedError, Sendable {
    case invalidRequest(String)

    var errorDescription: String? {
        switch self {
        case .invalidRequest(let reason):
            return "Invalid request: \(reason)"
        }
    }
}
