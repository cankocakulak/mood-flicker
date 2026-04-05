import Foundation
import SwiftData
import WidgetKit

/// Service responsible for SwiftData persistence operations
/// Handles CRUD operations for MoodEntry with background thread writes
@MainActor
final class MoodPersistenceService: ObservableObject {
    
    // MARK: - Properties
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    /// App group UserDefaults for sharing data with widget
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.com.moodflicker.app")
    }
    
    @Published var isSyncing: Bool = false
    @Published var lastSyncError: Error?
    
    // MARK: - Initialization
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
        
        // Configure context for background operations
        modelContext.autosaveEnabled = false
    }
    
    // MARK: - CRUD Operations
    
    /// Saves a new mood entry to SwiftData
    /// - Parameters:
    ///   - moodOption: The selected mood option
    ///   - intensityLevel: The intensity level
    ///   - tags: Selected tags
    /// - Returns: The saved MoodEntry
    /// - Throws: Persistence errors
    func saveMoodEntry(
        moodOption: MoodOption,
        intensityLevel: IntensityLevel,
        tags: Set<String>
    ) async throws -> MoodEntry {
        let entry = MoodEntry(
            moodOption: moodOption,
            intensityLevel: intensityLevel,
            tags: tags
        )
        
        // Perform write on background thread
        try await performBackgroundWrite { context in
            context.insert(entry)
            try context.save()
        }
        
        // Update widget with the new entry
        await updateWidgetWithLastEntry(entry)
        
        return entry
    }
    
    /// Updates the shared UserDefaults with the last mood entry for widget access
    /// - Parameter entry: The mood entry to share with the widget
    private func updateWidgetWithLastEntry(_ entry: MoodEntry) async {
        guard let defaults = sharedDefaults else { return }
        
        // Create a simple data representation for the widget
        let entryData: [String: Any] = [
            "id": entry.id.uuidString,
            "emoji": entry.emoji,
            "intensity": entry.intensity,
            "tags": entry.tags,
            "timestamp": entry.timestamp.timeIntervalSince1970
        ]
        
        defaults.set(entryData, forKey: "widget_lastMoodEntry")
        defaults.set(Date().timeIntervalSince1970, forKey: "widget_lastUpdateTime")
        
        // Reload widget timeline
        WidgetCenter.shared.reloadTimelines(ofKind: "MoodFlickerWidget")
    }
    
    /// Fetches all mood entries sorted by timestamp (newest first)
    /// - Returns: Array of MoodEntry objects
    /// - Throws: Fetch errors
    func fetchAllEntries() async throws -> [MoodEntry] {
        let descriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        return try await performBackgroundFetch { context in
            try context.fetch(descriptor)
        }
    }
    
    /// Fetches entries within a specific date range
    /// - Parameters:
    ///   - start: Start date
    ///   - end: End date
    /// - Returns: Array of MoodEntry objects in the date range
    /// - Throws: Fetch errors
    func fetchEntries(from start: Date, to end: Date) async throws -> [MoodEntry] {
        let predicate = MoodEntry.predicateForDateRange(start: start, end: end)
        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        return try await performBackgroundFetch { context in
            try context.fetch(descriptor)
        }
    }
    
    /// Fetches entries from the last N days
    /// - Parameter days: Number of days to look back
    /// - Returns: Array of MoodEntry objects
    /// - Throws: Fetch errors
    func fetchEntriesFromLastDays(_ days: Int) async throws -> [MoodEntry] {
        let predicate = MoodEntry.predicateForLastDays(days)
        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        return try await performBackgroundFetch { context in
            try context.fetch(descriptor)
        }
    }
    
    /// Fetches entries for a specific day
    /// - Parameter date: The date to fetch entries for
    /// - Returns: Array of MoodEntry objects for that day
    /// - Throws: Fetch errors
    func fetchEntriesForDay(_ date: Date) async throws -> [MoodEntry] {
        let predicate = MoodEntry.predicateForDay(date)
        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        return try await performBackgroundFetch { context in
            try context.fetch(descriptor)
        }
    }
    
    /// Deletes a specific mood entry
    /// - Parameter entry: The entry to delete
    /// - Throws: Deletion errors
    func deleteEntry(_ entry: MoodEntry) async throws {
        try await performBackgroundWrite { context in
            context.delete(entry)
            try context.save()
        }
    }
    
    /// Deletes all mood entries (use with caution)
    /// - Throws: Deletion errors
    func deleteAllEntries() async throws {
        let descriptor = FetchDescriptor<MoodEntry>()
        
        try await performBackgroundWrite { context in
            let entries = try context.fetch(descriptor)
            for entry in entries {
                context.delete(entry)
            }
            try context.save()
        }
    }
    
    // MARK: - Background Operations
    
    /// Performs a write operation on a background context
    /// - Parameter operation: The write operation to perform
    /// - Throws: Any errors from the operation
    private func performBackgroundWrite(
        operation: @escaping (ModelContext) throws -> Void
    ) async throws {
        try await Task.detached(priority: .userInitiated) { [modelContainer] in
            let backgroundContext = ModelContext(modelContainer)
            backgroundContext.autosaveEnabled = false
            
            do {
                try operation(backgroundContext)
            } catch {
                throw MoodPersistenceError.saveFailed(underlying: error)
            }
        }.value
    }
    
    /// Performs a fetch operation on a background context
    /// - Parameter operation: The fetch operation to perform
    /// - Returns: The fetched results
    /// - Throws: Any errors from the operation
    private func performBackgroundFetch<T>(
        operation: @escaping (ModelContext) throws -> T
    ) async throws -> T {
        try await Task.detached(priority: .userInitiated) { [modelContainer] in
            let backgroundContext = ModelContext(modelContainer)
            
            do {
                return try operation(backgroundContext)
            } catch {
                throw MoodPersistenceError.fetchFailed(underlying: error)
            }
        }.value
    }
    
    // MARK: - CloudKit Sync Status
    
    /// Checks if CloudKit sync is available
    var isCloudKitAvailable: Bool {
        // SwiftData automatically handles CloudKit sync when configured
        // This checks if the container is configured for CloudKit
        modelContainer.configurations.contains { config in
            config.cloudKitDatabase != nil
        }
    }
}

// MARK: - Errors

enum MoodPersistenceError: LocalizedError {
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Kaydedilemedi. Tekrar dene."
        case .fetchFailed:
            return "Veriler yüklenemedi."
        case .deleteFailed:
            return "Silme işlemi başarısız oldu."
        }
    }
    
    var failureReason: String? {
        switch self {
        case .saveFailed(let error),
             .fetchFailed(let error),
             .deleteFailed(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Preview Support

extension MoodPersistenceService {
    /// Creates a preview service with in-memory storage
    static func preview() -> MoodPersistenceService {
        let schema = Schema([MoodEntry.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        do {
            let container = try ModelContainer(
                for: MoodEntry.self,
                configurations: [configuration]
            )
            return MoodPersistenceService(modelContainer: container)
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
