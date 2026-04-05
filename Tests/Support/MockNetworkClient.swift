import Foundation
@testable import TemplateApp

actor MockNetworkClient: NetworkClient {
    var result: Result<Data, Error>
    var lastPath: String?

    init(result: Result<Data, Error>) {
        self.result = result
    }

    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint<Response>) async throws -> Response {
        lastPath = endpoint.path
        let data = try result.get()
        return try endpoint.decoder.decode(Response.self, from: data)
    }
}

struct MockHealthAPI: HealthAPI {
    var result: Result<HealthStatus, Error>

    func fetchHealth() async throws -> HealthStatus {
        try result.get()
    }
}

struct TestLogger: AppLogger {
    func debug(_ message: String) {}
    func error(_ message: String) {}
}
