import SwiftData
import SwiftUI

/// Main root view with tab-based navigation
struct RootView: View {
    @State private var selectedTab = 0

    @Binding var selectedMoodFromWidget: String?

    private let syncManager: CloudKitSyncManager
    private let persistenceService: MoodPersistenceService

    init(
        selectedMoodFromWidget: Binding<String?>,
        syncManager: CloudKitSyncManager,
        persistenceService: MoodPersistenceService)
    {
        _selectedMoodFromWidget = selectedMoodFromWidget
        self.syncManager = syncManager
        self.persistenceService = persistenceService
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MoodCheckInView(
                    preselectedMoodEmoji: $selectedMoodFromWidget,
                    persistenceService: persistenceService)
            }
            .tabItem {
                Label("Kayıt", systemImage: "face.smiling")
            }
            .tag(0)

            TrendsView(persistenceService: persistenceService)
                .tabItem {
                    Label("Trendler", systemImage: "chart.bar")
                }
                .tag(1)

            SettingsView(syncManager: syncManager, persistenceService: persistenceService)
                .tabItem {
                    Label("Ayarlar", systemImage: "gear")
                }
                .tag(2)
        }
        .task {
            await syncManager.checkICloudAvailability()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    Group {
        if let container = try? ModelContainer(for: MoodEntry.self, configurations: config) {
            RootView(
                selectedMoodFromWidget: .constant(nil),
                syncManager: CloudKitSyncManager(container: container),
                persistenceService: MoodPersistenceService(modelContainer: container))
                .modelContainer(container)
        }
    }
}
