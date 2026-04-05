import WidgetKit
import SwiftUI

/// Timeline entry for MoodFlicker widget
struct MoodEntryTimelineEntry: TimelineEntry {
    let date: Date
    let lastMoodEntry: MoodEntryData?
    let configuration: MoodWidgetConfiguration
}

/// Configuration for the widget
struct MoodWidgetConfiguration {
    let widgetFamily: WidgetFamily
}

/// Timeline provider for the widget
struct MoodTimelineProvider: TimelineProvider {
    typealias Entry = MoodEntryTimelineEntry
    
    /// App group UserDefaults for sharing data between app and widget
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.com.moodflicker.app")
    }
    
    /// Reads the last mood entry from shared UserDefaults
    private func readLastMoodEntry() -> MoodEntryData? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: WidgetUserDefaultsKeys.lastMoodEntry),
              let entry = try? JSONDecoder().decode(MoodEntryData.self, from: data) else {
            return nil
        }
        return entry
    }
    
    func placeholder(in context: Context) -> MoodEntryTimelineEntry {
        MoodEntryTimelineEntry(
            date: Date(),
            lastMoodEntry: nil,
            configuration: MoodWidgetConfiguration(widgetFamily: context.family)
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MoodEntryTimelineEntry) -> Void) {
        let entry = MoodEntryTimelineEntry(
            date: Date(),
            lastMoodEntry: readLastMoodEntry(),
            configuration: MoodWidgetConfiguration(widgetFamily: context.family)
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MoodEntryTimelineEntry>) -> Void) {
        // Create a timeline that refreshes every 15 minutes
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        let entry = MoodEntryTimelineEntry(
            date: currentDate,
            lastMoodEntry: readLastMoodEntry(),
            configuration: MoodWidgetConfiguration(widgetFamily: context.family)
        )
        
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}
