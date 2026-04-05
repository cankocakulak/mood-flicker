import Foundation

protocol HealthAPI: Sendable {
    func fetchHealth() async throws -> HealthStatus
}

struct LiveHealthAPI: HealthAPI {
    private let client: NetworkClient

    init(client: NetworkClient) {
        self.client = client
    }

    func fetchHealth() async throws -> HealthStatus {
        try await client.send(Endpoint(path: "health"))
    }
}
