import Foundation

struct AppEnvironment: Equatable {
    let name: BuildConfiguration
    let apiBaseURL: URL
    let webSocketURL: URL
    let apiKey: String?

    static let fallback = AppEnvironment(
        name: .debug,
        apiBaseURL: URL(string: "http://127.0.0.1:8080")!,
        webSocketURL: URL(string: "ws://127.0.0.1:8080/ws")!,
        apiKey: nil)

    static func live(bundle: Bundle = .main) throws -> AppEnvironment {
        try from(dictionary: bundle.infoDictionary ?? [:])
    }

    static func from(dictionary: [String: Any]) throws -> AppEnvironment {
        guard let rawName = dictionary["AppEnvironmentName"] as? String,
              let buildConfiguration = BuildConfiguration(rawValue: rawName)
        else {
            throw AppEnvironmentError.missingValue("AppEnvironmentName")
        }

        guard let apiBaseURLString = dictionary["AppAPIBaseURL"] as? String,
              let apiBaseURL = URL(string: apiBaseURLString)
        else {
            throw AppEnvironmentError.invalidURL("AppAPIBaseURL")
        }

        guard let webSocketURLString = dictionary["AppWebSocketURL"] as? String,
              let webSocketURL = URL(string: webSocketURLString)
        else {
            throw AppEnvironmentError.invalidURL("AppWebSocketURL")
        }

        let apiKey = dictionary["AppAPIKey"] as? String

        return AppEnvironment(
            name: buildConfiguration,
            apiBaseURL: apiBaseURL,
            webSocketURL: webSocketURL,
            apiKey: apiKey?.isEmpty == true ? nil : apiKey)
    }
}

enum AppEnvironmentError: Error, Equatable, LocalizedError {
    case missingValue(String)
    case invalidURL(String)

    var errorDescription: String? {
        switch self {
        case let .missingValue(key):
            "Missing environment value: \(key)"
        case let .invalidURL(key):
            "Invalid URL for environment value: \(key)"
        }
    }
}
