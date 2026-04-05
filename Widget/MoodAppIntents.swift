import AppIntents

/// App Intent for logging a mood check-in from the widget
/// This intent launches the app with a pre-selected mood emoji
struct LogMoodIntent: AppIntent {
    static var title: LocalizedStringResource = "Mood Kaydet"
    static var description = IntentDescription("Hızlı bir şekilde mood kaydı yap")
    
    /// The selected mood emoji
    @Parameter(title: "Mood", description: "Kaydetmek istediğiniz ruh hali")
    var moodEmoji: String
    
    init() {}
    
    init(moodEmoji: String) {
        self.moodEmoji = moodEmoji
    }
    
    func perform() async throws -> some IntentResult {
        // The actual mood logging happens in the app when it opens
        // This intent just opens the app with the selected mood
        return .result()
    }
}

/// Widget configuration intent for customizable widgets (iOS 17+)
struct MoodWidgetConfigIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "MoodFlicker Widget Ayarları"
    static var description = IntentDescription("Widget görünümünü özelleştir")
    
    /// Preferred mood emoji to highlight in the widget
    @Parameter(title: "Öne Çıkan Mood", description: "Widget'ta öne çıkarılacak ruh hali")
    var preferredMood: String?
    
    init() {}
}
