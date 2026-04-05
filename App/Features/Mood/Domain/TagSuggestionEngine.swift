import Foundation

/// Rule-based tag suggestion engine for Mood Flicker
/// Provides mood-based tag recommendations to help users quickly select relevant tags
struct TagSuggestionEngine {
    
    /// Returns suggested tags for a given mood option
    /// - Parameter mood: The selected mood emoji
    /// - Returns: Array of MoodTag suggestions, ordered by relevance (most relevant first)
    static func suggestions(for mood: MoodOption?) -> [MoodTag] {
        guard let mood = mood else {
            return []
        }
        
        switch mood {
        case .sad, .anxious:
            // Low energy / negative moods: suggest tired, anxious, sleepless
            return [.tired, .anxious, .sleepless, .stressed, .calm, .social, .productive, .energetic]
            
        case .happy:
            // Positive mood: suggest energetic, productive, social
            return [.energetic, .productive, .social, .calm, .tired, .anxious, .stressed, .sleepless]
            
        case .angry:
            // Angry mood: suggest stressed, tired
            return [.stressed, .tired, .anxious, .sleepless, .calm, .energetic, .social, .productive]
            
        case .neutral:
            // Neutral mood: balanced suggestions
            return [.calm, .productive, .tired, .energetic, .social, .anxious, .stressed, .sleepless]
        }
    }
    
    /// Returns the primary suggested tags (top 3) for a given mood
    /// - Parameter mood: The selected mood emoji
    /// - Returns: Array of top 3 most relevant MoodTag suggestions
    static func primarySuggestions(for mood: MoodOption?) -> [MoodTag] {
        let allSuggestions = suggestions(for: mood)
        return Array(allSuggestions.prefix(3))
    }
    
    /// Checks if a tag is a primary suggestion for the given mood
    /// - Parameters:
    ///   - tag: The tag to check
    ///   - mood: The selected mood
    /// - Returns: True if the tag is in the top 3 suggestions
    static func isPrimarySuggestion(_ tag: MoodTag, for mood: MoodOption?) -> Bool {
        guard let mood = mood else { return false }
        return primarySuggestions(for: mood).contains(tag)
    }
}

// MARK: - MoodTag Extensions

extension MoodTag {
    /// Returns a color associated with this tag for visual distinction
    var tagColor: Color {
        switch self {
        case .tired:
            return .gray
        case .energetic:
            return .orange
        case .anxious:
            return .purple
        case .calm:
            return .teal
        case .stressed:
            return .red
        case .productive:
            return .green
        case .social:
            return .blue
        case .sleepless:
            return .indigo
        }
    }
}
