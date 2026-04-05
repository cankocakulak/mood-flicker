import Foundation

actor URLSessionNetworkClient: NetworkClient {
    private let environment: AppEnvironment
    private let authProvider: AuthProviding
    private let logger: AppLogger
    private let session: URLSession

    init(
        environment: AppEnvironment,
        authProvider: AuthProviding,
        logger: AppLogger,
        session: URLSession = .shared)
    {
        self.environment = environment
        self.authProvider = authProvider
        self.logger = logger
        self.session = session
    }

    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint<Response>) async throws -> Response {
        let request = try await makeRequest(for: endpoint)
        logger.debug("HTTP \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8-body>"
            logger.error("HTTP \(httpResponse.statusCode) \(body)")
            throw NetworkError.server(statusCode: httpResponse.statusCode, body: body)
        }

        guard !data.isEmpty else {
            throw NetworkError.emptyResponse
        }

        return try endpoint.decoder.decode(Response.self, from: data)
    }

    private func makeRequest(for endpoint: Endpoint<some Any>) async throws -> URLRequest {
        guard var components = URLComponents(
            url: environment.apiBaseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false)
        else {
            throw NetworkError.invalidURL
        }

        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.timeoutInterval = 30

        var headers = endpoint.headers
        headers["Accept"] = headers["Accept"] ?? "application/json"
        if endpoint.body != nil {
            headers["Content-Type"] = headers["Content-Type"] ?? "application/json"
        }
        if let authorization = try await authProvider.authorizationHeader() {
            headers["Authorization"] = authorization
        }
        if let apiKey = environment.apiKey {
            headers["X-API-Key"] = apiKey
        }
        request.allHTTPHeaderFields = headers

        return request
    }
}
