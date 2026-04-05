import Foundation

/// Shared helper functions for the widget
struct WidgetSharedHelpers {
    /// Formats a date as a time string in Turkish locale
    static func formatTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    /// Returns a "time ago" string in Turkish
    static func timeAgoString(from date: Date) -> String {
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
}
