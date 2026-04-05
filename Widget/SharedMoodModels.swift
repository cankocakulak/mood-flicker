import Foundation

/// Represents the available mood options with their associated metadata
/// This is duplicated in the widget extension for independence
public enum MoodOption: String, CaseIterable, Identifiable, Sendable {
    case happy = "😊"
    case neutral = "😐"
    case sad = "😔"
    case angry = "😤"
    case anxious = "😰"
    
    public var id: String { rawValue }
    
    /// Display name for accessibility
    public var accessibilityLabel: String {
        switch self {
        case .happy: return "Mutlu"
        case .neutral: return "Nötr"
        case .sad: return "Üzgün"
        case .angry: return "Sinirli"
        case .anxious: return "Endişeli"
        }
    }
    
    /// Color name associated with this mood for theming
    public var colorName: String {
        switch self {
        case .happy: return "green"
        case .neutral: return "yellow"
        case .sad: return "blue"
        case .angry: return "red"
        case .anxious: return "purple"
        }
    }
}

/// Intensity levels for mood entries
public enum IntensityLevel: Int, CaseIterable, Sendable {
    case low = 1
    case medium = 2
    case high = 3
    
    public var description: String {
        switch self {
        case .low: return "Düşük"
        case .medium: return "Orta"
        case .high: return "Yüksek"
        }
    }
}

/// Simple model for widget to represent a mood entry
/// This is a lightweight version of the main app's MoodEntry
public struct MoodEntryData: Codable, Sendable {
    public let id: UUID
    public let emoji: String
    public let intensity: Int
    public let tags: [String]
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        emoji: String,
        intensity: Int,
        tags: [String] = [],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.emoji = emoji
        self.intensity = intensity
        self.tags = tags
        self.timestamp = timestamp
    }
    
    /// Formatted time string for display
    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: timestamp)
    }
    
    /// Formatted date string for display
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: timestamp)
    }
}

/// UserDefaults keys for widget communication
public enum WidgetUserDefaultsKeys {
    public static let lastMoodEntry = "widget_lastMoodEntry"
    public static let lastUpdateTime = "widget_lastUpdateTime"
}

/// Helper to get time ago string
public func timeAgoString(from date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    let components = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
    
    if let days = components.day, days > 0 {
        return days == 1 ? "Dün" : "\(days) gün önce"
    } else if let hours = components.hour, hours > 0 {
        return "\(hours) saat önce"
    } else if let minutes = components.minute, minutes > 0 {
        return "\(minutes) dk önce"
    } else {
        return "Az önce"
    }
}
