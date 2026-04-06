import Foundation
import SwiftData

/// SwiftData model representing a mood entry
/// Stores the user's mood check-in with emoji, intensity, tags, and timestamp
@Model
final class MoodEntry {
    /// Unique identifier for the entry
    @Attribute(.unique) var id: UUID

    /// The emoji representing the mood (e.g., "😊", "😔")
    var emoji: String

    /// The intensity level of the mood (1-3, representing low/medium/high)
    var intensity: Int

    /// Optional tags providing context to the mood
    var tags: [String]

    /// UTC timestamp when the entry was created
    var timestamp: Date

    /// Initializes a new MoodEntry with automatic timestamp generation
    /// - Parameters:
    ///   - emoji: The emoji string representing the mood
    ///   - intensity: The intensity level (1-3)
    ///   - tags: Optional array of context tags
    ///   - timestamp: Optional timestamp (defaults to current UTC time)
    init(
        emoji: String,
        intensity: Int,
        tags: [String] = [],
        timestamp: Date = Date())
    {
        id = UUID()
        self.emoji = emoji
        self.intensity = intensity
        self.tags = tags
        // Store as UTC for consistent cloud sync
        self.timestamp = timestamp
    }

    /// Convenience initializer from MoodOption and IntensityLevel enums
    /// - Parameters:
    ///   - moodOption: The selected mood option
    ///   - intensityLevel: The intensity level enum
    ///   - tags: Optional set of selected tag strings
    init(
        moodOption: MoodOption,
        intensityLevel: IntensityLevel,
        tags: Set<String> = [])
    {
        id = UUID()
        emoji = moodOption.rawValue
        intensity = intensityLevel.rawValue
        self.tags = Array(tags)
        timestamp = Date()
    }
}

// MARK: - Computed Properties

extension MoodEntry {
    /// Returns the timestamp in the user's local timezone for display
    var localTimestamp: Date {
        // The timestamp is stored in UTC (default Date behavior)
        // When displayed, it will be shown in the user's local timezone
        timestamp
    }

    /// Returns the MoodOption enum if the emoji matches a known mood
    var moodOption: MoodOption? {
        MoodOption(rawValue: emoji)
    }

    /// Returns the IntensityLevel enum for the stored intensity value
    var intensityLevel: IntensityLevel {
        IntensityLevel(rawValue: intensity) ?? .medium
    }

    /// Formatted date string for display in local timezone
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter.string(from: timestamp)
    }

    /// Formatted time string for display
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter.string(from: timestamp)
    }

    /// Returns a score representing the mood (1-5 scale for charting)
    /// Maps emoji to base score, adjusted by intensity
    var moodScore: Int {
        let baseScore = switch emoji {
        case MoodOption.happy.rawValue: 5
        case MoodOption.neutral.rawValue: 3
        case MoodOption.sad.rawValue: 2
        case MoodOption.angry.rawValue: 1
        case MoodOption.anxious.rawValue: 2
        default: 3
        }

        // Adjust by intensity: low intensity reduces impact, high increases
        let intensityModifier = intensity - 2 // -1, 0, or +1
        return max(1, min(5, baseScore + intensityModifier))
    }
}

// MARK: - Query Helpers

extension MoodEntry {
    /// Predicate for fetching entries within a date range
    static func predicateForDateRange(start: Date, end: Date) -> Predicate<MoodEntry> {
        #Predicate<MoodEntry> { entry in
            entry.timestamp >= start && entry.timestamp <= end
        }
    }

    /// Predicate for fetching entries from the last N days
    static func predicateForLastDays(_ days: Int) -> Predicate<MoodEntry> {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return #Predicate<MoodEntry> { entry in
            entry.timestamp >= startDate
        }
    }

    /// Predicate for fetching entries for a specific day
    static func predicateForDay(_ date: Date) -> Predicate<MoodEntry> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        return #Predicate<MoodEntry> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }
    }
}

// MARK: - Sample Data

extension MoodEntry {
    /// Sample entry for previews and testing
    static var sample: MoodEntry {
        MoodEntry(
            emoji: MoodOption.happy.rawValue,
            intensity: IntensityLevel.high.rawValue,
            tags: ["enerjik", "üretken"])
    }

    /// Array of sample entries for previews
    static var samples: [MoodEntry] {
        [
            MoodEntry(
                emoji: MoodOption.happy.rawValue,
                intensity: IntensityLevel.medium.rawValue,
                tags: ["sosyal"],
                timestamp: Date().addingTimeInterval(-3600 * 2) // 2 hours ago
            ),
            MoodEntry(
                emoji: MoodOption.sad.rawValue,
                intensity: IntensityLevel.low.rawValue,
                tags: ["yorgun"],
                timestamp: Date().addingTimeInterval(-3600 * 24) // 1 day ago
            ),
            MoodEntry(
                emoji: MoodOption.anxious.rawValue,
                intensity: IntensityLevel.high.rawValue,
                tags: ["anksiyetik", "uykusuz"],
                timestamp: Date().addingTimeInterval(-3600 * 48) // 2 days ago
            )
        ]
    }
}

extension MoodEntry: @unchecked Sendable {}
