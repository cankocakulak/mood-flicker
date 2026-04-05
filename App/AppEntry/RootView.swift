import SwiftUI
import SwiftData

/// Main root view with tab-based navigation
/// Contains Check-in, Trends, and Settings tabs
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    
    /// Binding for mood selection from widget deep link
    @Binding var selectedMoodFromWidget: String?
    
    /// CloudKit sync manager for iCloud sync status
    @StateObject private var syncManager: CloudKitSyncManager?
    
    /// Persistence service for data operations
    @State private var persistenceService: MoodPersistenceService?
    
    init(selectedMoodFromWidget: Binding<String?>) {
        self._selectedMoodFromWidget = selectedMoodFromWidget
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Check-in Tab
            NavigationStack {
                MoodCheckInView(preselectedMoodEmoji: $selectedMoodFromWidget)
            }
            .tabItem {
                Label("Kayıt", systemImage: "face.smiling")
            }
            .tag(0)
            
            // Trends Tab
            TrendsView()
                .tabItem {
                    Label("Trendler", systemImage: "chart.bar")
                }
                .tag(1)
            
            // Settings Tab
            Group {
                if let syncManager = syncManager, let persistenceService = persistenceService {
                    SettingsView(syncManager: syncManager, persistenceService: persistenceService)
                } else {
                    Text("Yükleniyor...")
                }
            }
            .tabItem {
                Label("Ayarlar", systemImage: "gear")
            }
            .tag(2)
        }
        .accentColor(.accentColor)
        .onAppear {
            setupSyncManager()
        }
    }
    
    /// Sets up the CloudKit sync manager and persistence service with the current model container
    private func setupSyncManager() {
        guard syncManager == nil else { return }
        
        // Get the model container from the environment
        let container = modelContext.container
        let manager = CloudKitSyncManager(container: container)
        let persistence = MoodPersistenceService(modelContainer: container)
        
        // Update on main thread
        DispatchQueue.main.async {
            self.syncManager = manager
            self.persistenceService = persistence
        }
    }
}

#Preview {
    RootView(selectedMoodFromWidget: .constant(nil))
}