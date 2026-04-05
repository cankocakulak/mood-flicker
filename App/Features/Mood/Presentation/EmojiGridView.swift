import SwiftUI

/// Represents the available mood options with their associated metadata
enum MoodOption: String, CaseIterable, Identifiable {
    case happy = "😊"
    case neutral = "😐"
    case sad = "😔"
    case angry = "😤"
    case anxious = "😰"
    
    var id: String { rawValue }
    
    /// Display name for accessibility
    var accessibilityLabel: String {
        switch self {
        case .happy: return "Mutlu"
        case .neutral: return "Nötr"
        case .sad: return "Üzgün"
        case .angry: return "Sinirli"
        case .anxious: return "Endişeli"
        }
    }
    
    /// Accessibility hint for the emoji button
    var accessibilityHint: String {
        "Ruh halini seçmek için dokun"
    }
    
    /// Color associated with this mood for theming
    var moodColor: Color {
        switch self {
        case .happy: return .green
        case .neutral: return .yellow
        case .sad: return .blue
        case .angry: return .red
        case .anxious: return .purple
        }
    }
}

/// A grid component for selecting mood emojis
/// Displays 5 emoji options with selection state, visual feedback, and haptic feedback
struct EmojiGridView: View {
    @Binding var selectedMood: MoodOption?
    @State private var hoveredMood: MoodOption?
    
    private let emojiSize: CGFloat = 48
    private let touchTargetSize: CGFloat = 60
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ForEach(MoodOption.allCases) { mood in
                emojiButton(for: mood)
            }
        }
        .padding(.vertical, AppTheme.Spacing.md)
        .onAppear {
            hapticFeedback.prepare()
        }
    }
    
    private func emojiButton(for mood: MoodOption) -> some View {
        let isSelected = selectedMood == mood
        let isHovered = hoveredMood == mood
        
        return Button(action: {
            selectMood(mood)
        }) {
            Text(mood.rawValue)
                .font(.system(size: emojiSize))
                .frame(width: touchTargetSize, height: touchTargetSize)
                .background(
                    Circle()
                        .fill(isSelected ? mood.moodColor.opacity(0.2) : Color.clear)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? mood.moodColor : Color.clear, lineWidth: 2)
                )
                .scaleEffect(isSelected ? 1.1 : (isHovered ? 1.05 : 1.0))
                .opacity(isSelected ? 1.0 : 0.6)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(mood.accessibilityLabel)
        .accessibilityHint(mood.accessibilityHint)
        .accessibilityValue(isSelected ? "Seçili" : "Seçilmedi")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .onHover { hovering in
            hoveredMood = hovering ? mood : nil
        }
    }
    
    private func selectMood(_ mood: MoodOption) {
        // Use centralized haptic manager with emoji-specific feedback
        HapticManager.shared.emojiSelected()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedMood = mood
        }
    }
}

// MARK: - Preview

#Preview("Emoji Grid - No Selection") {
    EmojiGridView(selectedMood: .constant(nil))
        .padding()
}

#Preview("Emoji Grid - Happy Selected") {
    EmojiGridView(selectedMood: .constant(.happy))
        .padding()
}

#Preview("Emoji Grid - Sad Selected") {
    EmojiGridView(selectedMood: .constant(.sad))
        .padding()
}