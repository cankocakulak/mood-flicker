@testable import TemplateApp
import XCTest

final class AppEnvironmentTests: XCTestCase {
    func testParsesEnvironmentDictionary() throws {
        let environment = try AppEnvironment.from(dictionary: [
            "AppEnvironmentName": "Staging",
            "AppAPIBaseURL": "https://staging.example.com",
            "AppWebSocketURL": "wss://staging.example.com/ws",
            "AppAPIKey": "secret"
        ])

        XCTAssertEqual(environment.name, .staging)
        XCTAssertEqual(environment.apiBaseURL.absoluteString, "https://staging.example.com")
        XCTAssertEqual(environment.webSocketURL.absoluteString, "wss://staging.example.com/ws")
        XCTAssertEqual(environment.apiKey, "secret")
    }

    func testThrowsWhenRequiredKeyMissing() {
        XCTAssertThrowsError(try AppEnvironment.from(dictionary: [:])) { error in
            XCTAssertEqual(error as? AppEnvironmentError, .missingValue("AppEnvironmentName"))
        }
    }
}
