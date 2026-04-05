import Foundation

/// Calculates and tracks mood check-in streaks
/// Streak = at least 1 entry in the last 24 hours
/// 48+ hours gap = streak pauses (hidden after 24h, not reset)
struct StreakCalculator {
    
    // MARK: - Types
    
    struct StreakInfo {
        let currentStreak: Int
        let isActive: Bool
        let lastEntryDate: Date?
        let hoursSinceLastEntry: Double?
        let shouldHide: Bool
        
        /// Positive messaging for the streak display
        var displayMessage: String? {
            guard isActive, currentStreak > 0 else { return nil }
            return "\(currentStreak) gündür kendini takip ediyorsun"
        }
        
        /// Accessibility label for VoiceOver
        var accessibilityLabel: String {
            if shouldHide {
                return "Streak bilgisi gizli"
            }
            if !isActive {
                if let hours = hoursSinceLastEntry {
                    let days = Int(hours / 24)
                    return "Streak durakladı. Son kayıt \(days) gün önce"
                }
                return "Henüz streak başlatılmadı"
            }
            return "\(currentStreak) günlük streak aktif"
        }
    }
    
    // MARK: - Constants
    
    /// 24 hours in seconds - streak window
    private static let streakWindow: TimeInterval = 24 * 60 * 60
    
    /// 48 hours in seconds - streak pause threshold
    private static let pauseThreshold: TimeInterval = 48 * 60 * 60
    
    /// 24 hours after pause - hide threshold
    private static let hideThreshold: TimeInterval = 72 * 60 * 60 // 48h pause + 24h hide
    
    // MARK: - Calculation
    
    /// Calculates streak information from a list of mood entries
    /// - Parameter entries: All mood entries sorted by timestamp (newest first)
    /// - Returns: StreakInfo with current streak and status
    static func calculateStreak(from entries: [MoodEntry]) -> StreakInfo {
        guard let mostRecentEntry = entries.first else {
            return StreakInfo(
                currentStreak: 0,
                isActive: false,
                lastEntryDate: nil,
                hoursSinceLastEntry: nil,
                shouldHide: true
            )
        }
        
        let now = Date()
        let lastEntryDate = mostRecentEntry.timestamp
        let hoursSinceLastEntry = now.timeIntervalSince(lastEntryDate) / 3600
        
        // Check if streak should be hidden (48h pause + 24h grace period)
        if hoursSinceLastEntry * 3600 >= hideThreshold {
            return StreakInfo(
                currentStreak: 0,
                isActive: false,
                lastEntryDate: lastEntryDate,
                hoursSinceLastEntry: hoursSinceLastEntry,
                shouldHide: true
            )
        }
        
        // Check if streak is paused (48+ hours gap)
        let isPaused = hoursSinceLastEntry * 3600 >= pauseThreshold
        
        if isPaused {
            return StreakInfo(
                currentStreak: calculateHistoricalStreak(from: entries),
                isActive: false,
                lastEntryDate: lastEntryDate,
                hoursSinceLastEntry: hoursSinceLastEntry,
                shouldHide: false // Show as paused, not hidden yet
            )
        }
        
        // Calculate active streak
        let streakCount = calculateActiveStreak(from: entries)
        
        return StreakInfo(
            currentStreak: streakCount,
            isActive: true,
            lastEntryDate: lastEntryDate,
            hoursSinceLastEntry: hoursSinceLastEntry,
            shouldHide: false
        )
    }
    
    /// Calculates the current active streak (consecutive days with at least 1 entry)
    /// - Parameter entries: All mood entries sorted by timestamp (newest first)
    /// - Returns: Number of consecutive days in the streak
    private static func calculateActiveStreak(from entries: [MoodEntry]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        // Get unique days with entries (normalized to start of day)
        var daysWithEntries = Set<DateComponents>()
        for entry in entries {
            let components = calendar.dateComponents([.year, .month, .day], from: entry.timestamp)
            daysWithEntries.insert(components)
        }
        
        // Check if there's an entry in the last 24 hours
        let mostRecentEntry = entries.first!.timestamp
        let hoursSinceLastEntry = now.timeIntervalSince(mostRecentEntry) / 3600
        
        guard hoursSinceLastEntry < 24 else {
            return 0 // Streak broken
        }
        
        // Count consecutive days going backwards
        var streakCount = 0
        var currentDate = now
        
        // Check today or yesterday (within 24h window)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let yesterdayComponents = calendar.dateComponents([.year, .month, .day], from: yesterday)
        
        // If there's an entry today or within last 24h, streak includes today
        if daysWithEntries.contains(todayComponents) || hoursSinceLastEntry < 24 {
            streakCount = 1
            
            // Count backwards through consecutive days
            var checkDate = yesterday
            while true {
                let checkComponents = calendar.dateComponents([.year, .month, .day], from: checkDate)
                if daysWithEntries.contains(checkComponents) {
                    streakCount += 1
                    checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                } else {
                    break
                }
            }
        }
        
        return streakCount
    }
    
    /// Calculates historical streak (for display when paused)
    /// Returns the longest streak that was achieved
    private static func calculateHistoricalStreak(from entries: [MoodEntry]) -> Int {
        // When paused, we show the streak that was achieved before pausing
        // This is calculated by counting consecutive days up to the gap
        let calendar = Calendar.current
        
        var daysWithEntries = Set<DateComponents>()
        for entry in entries {
            let components = calendar.dateComponents([.year, .month, .day], from: entry.timestamp)
            daysWithEntries.insert(components)
        }
        
        let sortedDays = daysWithEntries.sorted { c1, c2 in
            if c1.year != c2.year { return c1.year! > c2.year! }
            if c1.month != c2.month { return c1.month! > c2.month! }
            return c1.day! > c2.day!
        }
        
        guard !sortedDays.isEmpty else { return 0 }
        
        var currentStreak = 1
        var maxStreak = 1
        
        for i in 1..<sortedDays.count {
            let current = sortedDays[i]
            let previous = sortedDays[i-1]
            
            // Check if consecutive days
            if let currentDate = calendar.date(from: current),
               let previousDate = calendar.date(from: previous) {
                let daysBetween = calendar.dateComponents([.day], from: currentDate, to: previousDate).day!
                
                if daysBetween == 1 {
                    currentStreak += 1
                    maxStreak = max(maxStreak, currentStreak)
                } else {
                    // Gap found, streak broken
                    break
                }
            }
        }
        
        return maxStreak
    }
    
    // MARK: - Helpers
    
    /// Returns a friendly time ago string for the last entry
    static func timeAgoString(from date: Date) -> String {
        let hours = Date().timeIntervalSince(date) / 3600
        
        if hours < 1 {
            return "Az önce"
        } else if hours < 24 {
            let hourCount = Int(hours)
            return "\(hourCount) saat önce"
        } else {
            let days = Int(hours / 24)
            return "\(days) gün önce"
        }
    }
}

// MARK: - Preview Helpers

extension StreakCalculator.StreakInfo {
    static var active: StreakCalculator.StreakInfo {
        StreakCalculator.StreakInfo(
            currentStreak: 7,
            isActive: true,
            lastEntryDate: Date().addingTimeInterval(-3600 * 4), // 4 hours ago
            hoursSinceLastEntry: 4,
            shouldHide: false
        )
    }
    
    static var paused: StreakCalculator.StreakInfo {
        StreakCalculator.StreakInfo(
            currentStreak: 5,
            isActive: false,
            lastEntryDate: Date().addingTimeInterval(-3600 * 50), // 50 hours ago
            hoursSinceLastEntry: 50,
            shouldHide: false
        )
    }
    
    static var hidden: StreakCalculator.StreakInfo {
        StreakCalculator.StreakInfo(
            currentStreak: 0,
            isActive: false,
            lastEntryDate: Date().addingTimeInterval(-3600 * 100), // 100 hours ago
            hoursSinceLastEntry: 100,
            shouldHide: true
        )
    }
    
    static var empty: StreakCalculator.StreakInfo {
        StreakCalculator.StreakInfo(
            currentStreak: 0,
            isActive: false,
            lastEntryDate: nil,
            hoursSinceLastEntry: nil,
            shouldHide: true
        )
    }
}