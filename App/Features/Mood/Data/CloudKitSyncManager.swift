import CloudKit
import Combine
import Foundation
import SwiftData
import UIKit

@MainActor
final class CloudKitSyncManager: ObservableObject {
    // MARK: - Published Properties

    @Published var syncStatus: SyncStatus = .unknown
    @Published var isICloudAvailable: Bool = false
    @Published var lastError: Error?
    @Published var syncMessage: String?

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let container: ModelContainer
    private nonisolated(unsafe) var accountStatusObserver: NSObjectProtocol?

    // MARK: - Initialization

    init(container: ModelContainer) {
        self.container = container
        setupAccountStatusObserver()
    }

    deinit {
        if let observer = accountStatusObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Public Methods

    func checkICloudAvailability() async {
        do {
            let status = try await CKContainer.default().accountStatus()

            switch status {
            case .available:
                isICloudAvailable = true
                syncStatus = .synced
                lastError = nil
            case .noAccount:
                isICloudAvailable = false
                syncStatus = .iCloudDisabled
                lastError = CloudKitSyncError.iCloudAccountNotAvailable
            case .restricted:
                isICloudAvailable = false
                syncStatus = .restricted
                lastError = CloudKitSyncError.iCloudAccessRestricted
            case .couldNotDetermine:
                isICloudAvailable = false
                syncStatus = .unknown
                lastError = CloudKitSyncError.couldNotDetermineStatus
            @unknown default:
                isICloudAvailable = false
                syncStatus = .unknown
            }
        } catch {
            isICloudAvailable = false
            syncStatus = .error
            lastError = error
        }
    }

    func showSyncingIndicator() {
        syncMessage = "Senkronize ediliyor..."

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.syncMessage = nil
        }
    }

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
            queue: .main)
        { [weak self] _ in
            Task { @MainActor [weak self] in
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
        case .unknown: "Durum bilinmiyor"
        case .syncing: "Senkronize ediliyor..."
        case .synced: "Senkronize"
        case .iCloudDisabled: "iCloud kapalı"
        case .restricted: "Erişim kısıtlı"
        case .error: "Senkronizasyon hatası"
        }
    }

    var iconName: String {
        switch self {
        case .unknown: "questionmark.circle"
        case .syncing: "arrow.triangle.2.circlepath"
        case .synced: "checkmark.icloud"
        case .iCloudDisabled: "icloud.slash"
        case .restricted: "exclamationmark.icloud"
        case .error: "xmark.icloud"
        }
    }
}

// MARK: - CloudKit Errors

enum CloudKitSyncError: LocalizedError {
    case iCloudAccountNotAvailable
    case iCloudAccessRestricted
    case couldNotDetermineStatus

    var errorDescription: String? {
        switch self {
        case .iCloudAccountNotAvailable:
            "iCloud hesabı bulunamadı. Ayarlar'dan iCloud'a giriş yapın."
        case .iCloudAccessRestricted:
            "iCloud erişimi kısıtlanmış."
        case .couldNotDetermineStatus:
            "iCloud durumu belirlenemedi."
        }
    }
}
