import WidgetKit
import SwiftUI

/// Main MoodFlicker widget configuration
@main
struct MoodFlickerWidget: Widget {
    let kind: String = "MoodFlickerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: MoodTimelineProvider()
        ) { entry in
            MoodWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("MoodFlicker")
        .description("Hızlı mood check-in yapın ve son kayıtlarınızı görün.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

/// Preview provider for widget
#Preview(as: .systemSmall) {
    MoodFlickerWidget()
} timeline: {
    MoodEntryTimelineEntry(
        date: Date(),
        lastMoodEntry: nil,
        configuration: MoodWidgetConfiguration(widgetFamily: .systemSmall)
    )
}

#Preview(as: .systemMedium) {
    MoodFlickerWidget()
} timeline: {
    MoodEntryTimelineEntry(
        date: Date(),
        lastMoodEntry: nil,
        configuration: MoodWidgetConfiguration(widgetFamily: .systemMedium)
    )
}

#Preview(as: .systemLarge) {
    MoodFlickerWidget()
} timeline: {
    MoodEntryTimelineEntry(
        date: Date(),
        lastMoodEntry: nil,
        configuration: MoodWidgetConfiguration(widgetFamily: .systemLarge)
    )
}
