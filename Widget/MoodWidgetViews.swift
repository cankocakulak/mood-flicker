import WidgetKit
import SwiftUI

/// Widget view for small size (1 emoji)
struct SmallMoodWidgetView: View {
    var entry: MoodTimelineProvider.Entry
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
            
            VStack(spacing: 8) {
                // App icon / title
                Text("MoodFlicker")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                // Single emoji button
                Link(destination: URL(string: "moodflicker://checkin?mood=😊")!) {
                    Text("😊")
                        .font(.system(size: 40))
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.green.opacity(0.2))
                        )
                }
                
                // Last record info
                if let lastEntry = entry.lastMoodEntry {
                    Text(WidgetSharedHelpers.timeAgoString(from: lastEntry.timestamp))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                } else {
                    Text("İlk kaydı yap")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(8)
        }
    }
}

/// Widget view for medium size (3 emojis horizontal)
struct MediumMoodWidgetView: View {
    var entry: MoodTimelineProvider.Entry
    
    private let displayedMoods: [(emoji: String, color: Color)] = [
        ("😊", .green),
        ("😐", .yellow),
        ("😔", .blue)
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
            
            VStack(spacing: 12) {
                // Header
                HStack {
                    Text("MoodFlicker")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if let lastEntry = entry.lastMoodEntry {
                        Text(WidgetSharedHelpers.timeAgoString(from: lastEntry.timestamp))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Emoji row
                HStack(spacing: 20) {
                    ForEach(displayedMoods, id: \.emoji) { mood in
                        Link(destination: URL(string: "moodflicker://checkin?mood=\(mood.emoji)")!) {
                            Text(mood.emoji)
                                .font(.system(size: 36))
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(mood.color.opacity(0.2))
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

/// Widget view for large size (5 emojis + last record info)
struct LargeMoodWidgetView: View {
    var entry: MoodTimelineProvider.Entry
    
    private let allMoods: [(emoji: String, color: Color)] = [
        ("😊", .green),
        ("😐", .yellow),
        ("😔", .blue),
        ("😤", .red),
        ("😰", .purple)
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("MoodFlicker")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                // Emoji grid (5 emojis)
                HStack(spacing: 12) {
                    ForEach(allMoods, id: \.emoji) { mood in
                        Link(destination: URL(string: "moodflicker://checkin?mood=\(mood.emoji)")!) {
                            Text(mood.emoji)
                                .font(.system(size: 32))
                                .frame(width: 48, height: 48)
                                .background(
                                    Circle()
                                        .fill(mood.color.opacity(0.2))
                                )
                        }
                    }
                }
                
                Divider()
                
                // Last record section
                if let lastEntry = entry.lastMoodEntry {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Son Kayıt")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text(lastEntry.emoji)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(WidgetSharedHelpers.formatTime(from: lastEntry.timestamp))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                if !lastEntry.tags.isEmpty {
                                    Text(lastEntry.tags.prefix(3).joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("Henüz kayıt yok")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("Bir emoji seçerek başla")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(16)
        }
    }
}

/// Main widget entry view that switches based on widget family
struct MoodWidgetEntryView: View {
    var entry: MoodTimelineProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallMoodWidgetView(entry: entry)
        case .systemMedium:
            MediumMoodWidgetView(entry: entry)
        case .systemLarge:
            LargeMoodWidgetView(entry: entry)
        default:
            SmallMoodWidgetView(entry: entry)
        }
    }
}
