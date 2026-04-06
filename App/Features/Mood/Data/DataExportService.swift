import Combine
import Foundation
import SwiftData

/// Service responsible for data export operations
/// Generates JSON and CSV exports of mood entries with date range filtering
@MainActor
final class DataExportService: ObservableObject {
    // MARK: - Properties

    private let persistenceService: MoodPersistenceService

    @Published var isExporting: Bool = false
    @Published var exportProgress: Double = 0.0
    @Published var lastExportError: Error?
    @Published var lastExportedURL: URL?

    // MARK: - Initialization

    init(persistenceService: MoodPersistenceService) {
        self.persistenceService = persistenceService
    }

    // MARK: - Export Operations

    /// Exports mood entries to JSON format
    /// - Parameters:
    ///   - entries: The mood entries to export
    ///   - dateRange: Optional date range description for filename
    /// - Returns: URL to the exported file
    /// - Throws: Export errors
    func exportToJSON(
        entries: [MoodEntry],
        dateRange: String? = nil) async throws -> URL
    {
        guard !entries.isEmpty else {
            throw DataExportError.noDataToExport
        }

        let exportData = entries.map { entry in
            MoodEntryExport(
                id: entry.id.uuidString,
                emoji: entry.emoji,
                intensity: entry.intensity,
                tags: entry.tags,
                timestamp: entry.timestamp,
                timestampISO8601: ISO8601DateFormatter().string(from: entry.timestamp))
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let jsonData = try encoder.encode(exportData)

        let filename = generateFilename(format: "json", dateRange: dateRange)
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        try jsonData.write(to: fileURL)

        return fileURL
    }

    /// Exports mood entries to CSV format
    /// - Parameters:
    ///   - entries: The mood entries to export
    ///   - dateRange: Optional date range description for filename
    /// - Returns: URL to the exported file
    /// - Throws: Export errors
    func exportToCSV(
        entries: [MoodEntry],
        dateRange: String? = nil) async throws -> URL
    {
        guard !entries.isEmpty else {
            throw DataExportError.noDataToExport
        }

        var csvString = "timestamp,emoji,intensity,tags\n"

        let dateFormatter = ISO8601DateFormatter()

        for entry in entries {
            let timestamp = dateFormatter.string(from: entry.timestamp)
            let emoji = entry.emoji
            let intensity = String(entry.intensity)
            let tags = entry.tags.joined(separator: ";")

            csvString += "\(timestamp),\(emoji),\(intensity),\"\(tags)\"\n"
        }

        guard let csvData = csvString.data(using: .utf8) else {
            throw DataExportError.encodingFailed
        }

        let filename = generateFilename(format: "csv", dateRange: dateRange)
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        try csvData.write(to: fileURL)

        return fileURL
    }

    /// Fetches and exports entries with progress tracking
    /// - Parameters:
    ///   - format: Export format (json or csv)
    ///   - startDate: Optional start date filter
    ///   - endDate: Optional end date filter
    /// - Returns: URL to the exported file
    /// - Throws: Export errors
    func exportEntries(
        format: ExportFormat,
        startDate: Date? = nil,
        endDate: Date? = nil) async throws -> URL
    {
        await MainActor.run {
            isExporting = true
            exportProgress = 0.0
            lastExportError = nil
        }

        defer {
            Task { @MainActor in
                isExporting = false
                exportProgress = 1.0
            }
        }

        // Fetch entries
        let entries: [MoodEntry] = if let start = startDate, let end = endDate {
            try await persistenceService.fetchEntries(from: start, to: end)
        } else {
            try await persistenceService.fetchAllEntries()
        }

        await MainActor.run {
            exportProgress = 0.5
        }

        // Generate date range description for filename
        let dateRangeDescription = generateDateRangeDescription(startDate: startDate, endDate: endDate)

        // Export based on format
        let fileURL: URL = switch format {
        case .json:
            try await exportToJSON(entries: entries, dateRange: dateRangeDescription)
        case .csv:
            try await exportToCSV(entries: entries, dateRange: dateRangeDescription)
        }

        await MainActor.run {
            lastExportedURL = fileURL
            exportProgress = 1.0
        }

        return fileURL
    }

    /// Checks if there is any data to export
    /// - Returns: True if there are entries to export
    func hasDataToExport() async -> Bool {
        do {
            let entries = try await persistenceService.fetchAllEntries()
            return !entries.isEmpty
        } catch {
            return false
        }
    }

    /// Gets the count of entries available for export
    /// - Returns: Number of entries
    func getEntryCount() async -> Int {
        do {
            let entries = try await persistenceService.fetchAllEntries()
            return entries.count
        } catch {
            return 0
        }
    }

    // MARK: - Helper Methods

    private func generateFilename(format: String, dateRange: String?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())

        if let range = dateRange {
            return "mood-flicker-export-\(range)-\(dateString).\(format)"
        } else {
            return "mood-flicker-export-\(dateString).\(format)"
        }
    }

    private func generateDateRangeDescription(startDate: Date?, endDate: Date?) -> String? {
        guard startDate != nil || endDate != nil else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let start = startDate, let end = endDate {
            return "\(dateFormatter.string(from: start))-to-\(dateFormatter.string(from: end))"
        } else if let start = startDate {
            return "from-\(dateFormatter.string(from: start))"
        } else if let end = endDate {
            return "until-\(dateFormatter.string(from: end))"
        }

        return nil
    }

    /// Fetches entries for a date range (used by `DataExportView`).
    func fetchEntriesForDateRange(start: Date, end: Date) async throws -> [MoodEntry] {
        let calendar = Calendar.current
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end
        return try await persistenceService.fetchEntries(from: start, to: endOfDay)
    }
}

// MARK: - Export Format Enum

enum ExportFormat: String, CaseIterable, Identifiable {
    case json
    case csv

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .json:
            "JSON (Tam Veri)"
        case .csv:
            "CSV (Basit Analiz)"
        }
    }

    var description: String {
        switch self {
        case .json:
            "Tüm alanları içeren detaylı veri formatı"
        case .csv:
            "Excel veya analiz için basit tablo formatı"
        }
    }

    var iconName: String {
        switch self {
        case .json:
            "curlybraces"
        case .csv:
            "tablecells"
        }
    }
}

// MARK: - Export Data Model

struct MoodEntryExport: Codable {
    let id: String
    let emoji: String
    let intensity: Int
    let tags: [String]
    let timestamp: Date
    let timestampISO8601: String
}

// MARK: - Errors

enum DataExportError: LocalizedError {
    case noDataToExport
    case encodingFailed
    case fileWriteFailed
    case invalidDateRange

    var errorDescription: String? {
        switch self {
        case .noDataToExport:
            "Aktarılacak veri yok"
        case .encodingFailed:
            "Veri kodlanamadı"
        case .fileWriteFailed:
            "Dosya oluşturulamadı"
        case .invalidDateRange:
            "Geçersiz tarih aralığı"
        }
    }

    var failureReason: String? {
        switch self {
        case .noDataToExport:
            "Dışa aktarılacak mood kaydı bulunamadı. Önce birkaç kayıt oluşturun."
        case .encodingFailed:
            "Veri dışa aktarım formatına dönüştürülürken bir hata oluştu."
        case .fileWriteFailed:
            "Geçici dosya oluşturulurken bir hata oluştu."
        case .invalidDateRange:
            "Seçilen tarih aralığı geçersiz. Başlangıç tarihi bitiş tarihinden önce olmalıdır."
        }
    }
}

// MARK: - Preview Support

extension DataExportService {
    /// Creates a preview service with in-memory storage
    static func preview() -> DataExportService {
        let persistenceService = MoodPersistenceService.preview()
        return DataExportService(persistenceService: persistenceService)
    }
}
