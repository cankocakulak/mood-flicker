import Foundation
import SwiftData

struct AppContainer {
    let environment: AppEnvironment
    let authProvider: AuthProviding
    let networkClient: NetworkClient
    let logger: AppLogger
    let keyValueStore: KeyValueStore
    
    /// Creates a MoodPersistenceService with the given model container
    /// - Parameter modelContainer: The SwiftData model container
    /// - Returns: Configured MoodPersistenceService
    @MainActor
    func makeMoodPersistenceService(modelContainer: ModelContainer) -> MoodPersistenceService {
        MoodPersistenceService(modelContainer: modelContainer)
    }

    static func live(bundle: Bundle = .main) -> AppContainer {
        let environment = (try? AppEnvironment.live(bundle: bundle)) ?? .fallback
        let logger = AppLoggerFactory.live(subsystem: "com.moodflicker.app")
        let authProvider = StaticTokenAuthProvider(token: nil)
        let keyValueStore = UserDefaultsStore(userDefaults: .standard)
        let networkClient = URLSessionNetworkClient(
            environment: environment,
            authProvider: authProvider,
            logger: logger)

        return AppContainer(
            environment: environment,
            authProvider: authProvider,
            networkClient: networkClient,
            logger: logger,
            keyValueStore: keyValueStore)
    }
}