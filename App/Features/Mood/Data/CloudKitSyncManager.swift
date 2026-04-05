import Foundation
import CloudKit
import SwiftData
import Combine

/// Manages CloudKit synchronization status and iCloud availability
@MainActor
final class CloudKitSyncManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current sync status
    @Published var syncStatus: SyncStatus = .unknown
    
    /// Whether iCloud is available and user is signed in
    @Published var isICloudAvailable: Bool = false
    
    /// Last sync error if any
    @Published var lastError: Error?
    
    /// Non-blocking sync indicator message
    @Published var syncMessage: String?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let container: ModelContainer
    private var accountStatusObserver: NSObjectProtocol?
    
    // MARK: - Initialization
    
    init(container: ModelContainer) {
        self.container = container
        
        // Initial check
        Task {
            await checkICloudAvailability()
        }
        
        // Setup notification observers for iCloud account changes
        setupAccountStatusObserver()
    }
    
    deinit {
        if let observer = accountStatusObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Public Methods
    
    /// Checks iCloud account status and updates published properties
    func checkICloudAvailability() async {
        do {
            let status = try await CKContainer.default().accountStatus()
            
            await MainActor.run {
                switch status {
                case .available:
                    self.isICloudAvailable = true
                    self.syncStatus = .synced
                    self.lastError = nil
                case .noAccount:
                    self.isICloudAvailable = false
                    self.syncStatus = .iCloudDisabled
                    self.lastError = CloudKitSyncError.iCloudAccountNotAvailable
                case .restricted:
                    self.isICloudAvailable = false
                    self.syncStatus = .restricted
                    self.lastError = CloudKitSyncError.iCloudAccessRestricted
                case .couldNotDetermine:
                    self.isICloudAvailable = false
                    self.syncStatus = .unknown
                    self.lastError = CloudKitSyncError.couldNotDetermineStatus
                @unknown default:
                    self.isICloudAvailable = false
                    self.syncStatus = .unknown
                }
            }
        } catch {
            await MainActor.run {
                self.isICloudAvailable = false
                self.syncStatus = .error
                self.lastError = error
            }
        }
    }
    
    /// Shows a non-blocking sync indicator temporarily
    func showSyncingIndicator() {
        syncMessage = "Senkronize ediliyor..."
        
        // Auto-hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.syncMessage = nil
        }
    }
    
    /// Opens iCloud settings in the Settings app
    func openICloudSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAccountStatusObserver() {
        accountStatusObserver = NotificationCenter.default.addObserver(
            forName: .CKAccountChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.checkICloudAvailability()
            }
        }
    }
}

// MARK: - Sync Status Enum

enum SyncStatus: Equatable {
    case unknown
    case syncing
    case synced
    case iCloudDisabled
    case restricted
    case error
    
    var description: String {
        switch self {
        case .unknown:
            return "Durum bilinmiyor"
        case .syncing:
            return "Senkronize ediliyor..."
        case .synced:
            return "Senkronize"
        case .iCloudDisabled:
            return "iCloud kapalı"
        case .restricted:
            return "Erişim kısıtlı"
        case .error:
            return "Senkronizasyon hatası"
        }
    }
    
    var iconName: String {
        switch self {
        case .unknown:
            return "icloud.question"
        case .syncing:
            return "icloud.and.arrow.up"
        case .synced:
            return "icloud.checkmark"
        case .iCloudDisabled:
            return "icloud.slash"
        case .restricted:
            return "icloud.slash"
        case .error:
            return "icloud.exclamationmark"
        }
    }
    
    var color: String {
        switch self {
        case .unknown:
            return "gray"
        case .syncing:
            return "blue"
        case .synced:
            return "green"
        case .iCloudDisabled:
            return "orange"
        case .restricted:
            return "red"
        case .error:
            return "red"
        }
    }
}

// MARK: - Errors

enum CloudKitSyncError: LocalizedError {
    case iCloudAccountNotAvailable
    case iCloudAccessRestricted
    case couldNotDetermineStatus
    case syncFailed(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .iCloudAccountNotAvailable:
            return "iCloud hesabı bulunamadı"
        case .iCloudAccessRestricted:
            return "iCloud erişimi kısıtlandı"
        case .couldNotDetermineStatus:
            return "iCloud durumu belirlenemedi"
        case .syncFailed:
            return "Senkronizasyon başarısız oldu"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .iCloudAccountNotAvailable:
            return "Ayarlar'dan iCloud'a giriş yapabilirsiniz."
        case .iCloudAccessRestricted:
            return "Ebeveyn kontrolleri veya kuruluş politikaları iCloud erişimini kısıtlıyor olabilir."
        case .couldNotDetermineStatus:
            return "Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin."
        case .syncFailed:
            return "Tekrar deneyin veya destek ile iletişime geçin."
        }
    }
}
