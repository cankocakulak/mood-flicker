import Foundation

protocol NetworkClient: Sendable {
    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint<Response>) async throws -> Response
}

enum NetworkError: Error, Equatable, LocalizedError {
    case invalidURL
    case invalidResponse
    case server(statusCode: Int, body: String)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid request URL"
        case .invalidResponse:
            "Invalid server response"
        case let .server(statusCode, body):
            "Server error \(statusCode): \(body)"
        case .emptyResponse:
            "Expected response body but received none"
        }
    }
}
