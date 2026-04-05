import Foundation

struct AppContainer {
    let environment: AppEnvironment
    let authProvider: AuthProviding
    let networkClient: NetworkClient
    let healthAPI: HealthAPI
    let logger: AppLogger
    let keyValueStore: KeyValueStore

    static func live(bundle: Bundle = .main) -> AppContainer {
        let environment = (try? AppEnvironment.live(bundle: bundle)) ?? .fallback
        let logger = AppLoggerFactory.live(subsystem: "com.example.templateapp")
        let authProvider = StaticTokenAuthProvider(token: nil)
        let keyValueStore = UserDefaultsStore(userDefaults: .standard)
        let networkClient = URLSessionNetworkClient(
            environment: environment,
            authProvider: authProvider,
            logger: logger)
        let healthAPI = LiveHealthAPI(client: networkClient)

        return AppContainer(
            environment: environment,
            authProvider: authProvider,
            networkClient: networkClient,
            healthAPI: healthAPI,
            logger: logger,
            keyValueStore: keyValueStore)
    }
}
