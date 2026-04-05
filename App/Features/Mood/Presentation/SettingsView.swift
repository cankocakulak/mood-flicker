import SwiftUI

/// Settings view with iCloud sync status and app configuration options
struct SettingsView: View {
    @StateObject private var syncManager: CloudKitSyncManager
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    private let persistenceService: MoodPersistenceService
    
    init(syncManager: CloudKitSyncManager, persistenceService: MoodPersistenceService) {
        _syncManager = StateObject(wrappedValue: syncManager)
        self.persistenceService = persistenceService
    }
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Appearance Section
                Section {
                    ForEach(ThemePreference.allCases) { preference in
                        Button {
                            themeManager.setTheme(preference)
                        } label: {
                            HStack {
                                Image(systemName: preference.iconName)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 24)
                                
                                Text(preference.displayName)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if themeManager.themePreference == preference {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                        .font(.caption.weight(.semibold))
                                }
                            }
                        }
                    }
                } header: {
                    Text("Görünüm")
                } footer: {
                    Text("Sistem seçeneği, cihazınızın ayarlarına otomatik olarak uyum sağlar.")
                }
                
                // MARK: - Data Management Section
                Section {
                    NavigationLink {
                        DataExportView(persistenceService: persistenceService)
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Verileri Dışa Aktar")
                                    .font(.body)
                                
                                Text("JSON veya CSV olarak kaydet")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Veri Yönetimi")
                } footer: {
                    Text("Verilerinizi dışa aktararak yedekleyebilir veya başka uygulamalarda kullanabilirsiniz.")
                }
                
                // MARK: - iCloud Sync Section
                Section {
                    // iCloud Status Banner
                    if !syncManager.isICloudAvailable {
                        iCloudDisabledBanner
                    }
                    
                    // Sync Status Row
                    HStack {
                        Image(systemName: syncManager.syncStatus.iconName)
                            .foregroundColor(syncStatusColor)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("iCloud Senkronizasyonu")
                                .font(.body)
                            
                            Text(syncManager.syncStatus.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if syncManager.syncStatus == .syncing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Manual refresh button
                    Button {
                        Task {
                            await syncManager.checkICloudAvailability()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Durumu Yenile")
                        }
                    }
                    .disabled(syncManager.syncStatus == .syncing)
                } header: {
                    Text("Bulut Senkronizasyonu")
                } footer: {
                    if syncManager.isICloudAvailable {
                        Text("Verileriniz otomatik olarak iCloud'da senkronize edilir ve tüm cihazlarınızda kullanılabilir.")
                    } else {
                        Text("iCloud senkronizasyonu etkinleştirildiğinde, verileriniz tüm cihazlarınızda kullanılabilir olacak.")
                    }
                }
                
                // MARK: - About Section
                Section("Hakkında") {
                    HStack {
                        Text("Uygulama")
                        Spacer()
                        Text("Mood Flicker")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Sürüm")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Geliştirici")
                        Spacer()
                        Text("Mood Flicker Team")
                            .foregroundColor(.secondary)
                    }
                }
                
                // MARK: - Legal Section
                Section("Yasal") {
                    Link(destination: URL(string: "https://moodflicker.app/privacy")!) {
                        HStack {
                            Text("Gizlilik Politikası")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Link(destination: URL(string: "https://moodflicker.app/terms")!) {
                        HStack {
                            Text("Kullanım Koşulları")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Bitti") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - iCloud Disabled Banner
    
    private var iCloudDisabledBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "icloud.slash")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("iCloud Kapalı")
                        .font(.headline)
                    
                    Text("Verileriniz bu cihazda saklanıyor. Diğer cihazlarınızda görmek için iCloud'u etkinleştirin.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            
            Button {
                syncManager.openICloudSettings()
            } label: {
                HStack {
                    Image(systemName: "gear")
                    Text("Ayarları Aç")
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.accentColor)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .padding(.vertical, 4)
    }
    
    // MARK: - Helper Properties
    
    private var syncStatusColor: Color {
        switch syncManager.syncStatus {
        case .unknown:
            return .gray
        case .syncing:
            return .blue
        case .synced:
            return .green
        case .iCloudDisabled:
            return .orange
        case .restricted:
            return .red
        case .error:
            return .red
        }
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Preview

#Preview {
    let schema = Schema([MoodEntry.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    do {
        let container = try ModelContainer(for: MoodEntry.self, configurations: [configuration])
        let syncManager = CloudKitSyncManager(container: container)
        let persistenceService = MoodPersistenceService(modelContainer: container)
        return SettingsView(syncManager: syncManager, persistenceService: persistenceService)
    } catch {
        return Text("Preview Error")
    }
}
