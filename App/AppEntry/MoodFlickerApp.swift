import SwiftUI
import SwiftData

@main
struct MoodFlickerApp: App {
    private let container = AppContainer.live()
    
    /// SwiftData model container for persistence and CloudKit sync
    let modelContainer: ModelContainer
    
    /// State for handling widget deep links
    @State private var selectedMoodFromWidget: String?
    
    /// Theme manager for app-wide theme preference
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        // Configure SwiftData with CloudKit support
        let schema = Schema([MoodEntry.self])
        
        // Configure for local persistence with CloudKit sync
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            modelContainer = try ModelContainer(
                for: MoodEntry.self,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(selectedMoodFromWidget: $selectedMoodFromWidget)
                .environment(\.modelContext, modelContainer.mainContext)
                .preferredColorScheme(themeManager.colorScheme)
                .onOpenURL { url in
                    handleWidgetURL(url)
                }
        }
        .modelContainer(modelContainer)
    }
    
    /// Handles URL scheme invocations from the widget
    /// - Parameter url: The URL containing the mood selection
    private func handleWidgetURL(_ url: URL) {
        guard url.scheme == "moodflicker",
              url.host == "checkin",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let moodParam = components.queryItems?.first(where: { $0.name == "mood" })?.value else {
            return
        }
        
        // Set the selected mood to trigger the check-in flow
        selectedMoodFromWidget = moodParam
    }
}