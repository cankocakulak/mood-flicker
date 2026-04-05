import Foundation

struct HealthStatus: Decodable, Equatable {
    let ok: Bool
    let timestamp: Date?
    let services: [String: String]?

    static let mock = HealthStatus(
        ok: true,
        timestamp: Date(timeIntervalSince1970: 0),
        services: ["database": "healthy"])
}
