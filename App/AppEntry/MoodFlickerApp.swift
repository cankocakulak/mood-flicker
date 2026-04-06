import SwiftData
import SwiftUI

@main
struct MoodFlickerApp: App {
    let modelContainer: ModelContainer
    let persistenceService: MoodPersistenceService
    let syncManager: CloudKitSyncManager

    @State private var selectedMoodFromWidget: String?

    init() {
        let schema = Schema([MoodEntry.self])

        #if targetEnvironment(simulator)
        let cloudKitDB: ModelConfiguration.CloudKitDatabase = .none
        #else
        let cloudKitDB: ModelConfiguration.CloudKitDatabase = .automatic
        #endif

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: cloudKitDB)

        do {
            let mc = try ModelContainer(for: MoodEntry.self, configurations: config)
            modelContainer = mc
            persistenceService = MoodPersistenceService(modelContainer: mc)
            syncManager = CloudKitSyncManager(container: mc)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                selectedMoodFromWidget: $selectedMoodFromWidget,
                syncManager: syncManager,
                persistenceService: persistenceService)
                .preferredColorScheme(ThemeManager.shared.colorScheme)
                .onOpenURL { url in
                    handleWidgetURL(url)
                }
        }
        .modelContainer(modelContainer)
    }

    private func handleWidgetURL(_ url: URL) {
        guard url.scheme == "moodflicker",
              url.host == "checkin",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let moodParam = components.queryItems?.first(where: { $0.name == "mood" })?.value
        else { return }

        selectedMoodFromWidget = moodParam
    }
}
