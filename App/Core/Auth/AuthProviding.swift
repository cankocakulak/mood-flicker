import Foundation

protocol AuthProviding: Sendable {
    func authorizationHeader() async throws -> String?
}

struct StaticTokenAuthProvider: AuthProviding {
    let token: String?

    func authorizationHeader() async throws -> String? {
        guard let token, !token.isEmpty else { return nil }
        return "Bearer \(token)"
    }
}
