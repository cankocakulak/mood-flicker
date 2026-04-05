@testable import TemplateApp
import XCTest

final class EndpointTests: XCTestCase {
    func testDefaultDecoderUsesSnakeCaseConversion() throws {
        let data = Data(
            """
            {
              "ok": true,
              "timestamp": "2024-01-01T00:00:00Z",
              "services": {
                "database": "healthy"
              }
            }
            """.utf8)

        let status = try Endpoint<HealthStatus>(path: "health").decoder.decode(HealthStatus.self, from: data)

        XCTAssertTrue(status.ok)
        XCTAssertEqual(status.services?["database"], "healthy")
    }
}
