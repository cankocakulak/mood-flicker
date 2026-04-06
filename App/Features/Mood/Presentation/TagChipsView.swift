import SwiftUI

/// Represents the available mood tags
enum MoodTag: String, CaseIterable, Identifiable {
    case tired = "yorgun"
    case energetic = "enerjik"
    case anxious = "anksiyetik"
    case calm = "sakin"
    case stressed = "stresli"
    case productive = "üretken"
    case social = "sosyal"
    case sleepless = "uykusuz"

    var id: String {
        rawValue
    }

    /// Display label for the tag
    var displayLabel: String {
        rawValue.capitalized
    }

    /// Accessibility label for VoiceOver
    var accessibilityLabel: String {
        "\(displayLabel) etiketi"
    }

    /// Returns a color associated with this tag for visual distinction
    var tagColor: Color {
        switch self {
        case .tired:
            .gray
        case .energetic:
            .orange
        case .anxious:
            .purple
        case .calm:
            .teal
        case .stressed:
            .red
        case .productive:
            .green
        case .social:
            .blue
        case .sleepless:
            .indigo
        }
    }
}

/// A horizontal scrollable tag chips component for mood context selection
/// Supports toggle selection, max 3 limit with shake animation and toast feedback
/// Displays mood-based tag suggestions at the beginning of the list
struct TagChipsView: View {
    @Binding var selectedTags: Set<String>
    let selectedMood: MoodOption?
    let maxSelectionCount: Int = 3

    @State private var shakeTrigger: Bool = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    private let chipHeight: CGFloat = 36
    private let chipPadding: CGFloat = 16

    /// Computed property that returns tags ordered by suggestions for the current mood
    private var orderedTags: [MoodTag] {
        TagSuggestionEngine.suggestions(for: selectedMood)
    }

    /// Primary suggestions for highlighting
    private var primarySuggestions: [MoodTag] {
        TagSuggestionEngine.primarySuggestions(for: selectedMood)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Section header with suggestion indicator
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Etiketler (opsiyonel)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    // Show suggestion hint when mood is selected
                    if selectedMood != nil {
                        Text("Sana önerilenler: \(primarySuggestions.map(\.displayLabel).joined(separator: ", "))")
                            .font(.caption)
                            .foregroundStyle(Color.accentColor)
                    }
                }

                Spacer()

                // Selection count indicator
                Text("\(selectedTags.count)/\(maxSelectionCount)")
                    .font(.caption)
                    .foregroundStyle(selectedTags.count >= maxSelectionCount ? .orange : .secondary)
                    .fontWeight(selectedTags.count >= maxSelectionCount ? .semibold : .regular)
            }

            // Horizontal scrollable tag chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(orderedTags) { tag in
                        tagChip(for: tag)
                    }
                }
                .padding(.horizontal, 1) // Prevent clipping from shake animation
                .padding(.vertical, AppTheme.Spacing.xs)
            }
        }
        .overlay(alignment: .bottom) {
            if showToast {
                Text(toastMessage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.8)))
                    .padding(.bottom, AppTheme.Spacing.lg)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showToast)
    }

    private func tagChip(for tag: MoodTag) -> some View {
        let isSelected = selectedTags.contains(tag.rawValue)
        let isSuggested = primarySuggestions.contains(tag)

        return Button(action: {
            toggleTag(tag)
        }) {
            HStack(spacing: 4) {
                // Show star icon for suggested tags
                if isSuggested, !isSelected {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundStyle(tag.tagColor)
                }

                Text(tag.displayLabel)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)
            }
            .foregroundStyle(isSelected ? .white : (isSuggested ? tag.tagColor : .primary))
            .padding(.horizontal, chipPadding)
            .frame(height: chipHeight)
            .background(
                Capsule()
                    .fill(isSelected ? tag.tagColor : Color.clear))
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : (isSuggested ? tag.tagColor.opacity(0.5) : Color.gray.opacity(0.3)),
                        lineWidth: isSuggested ? 2 : 1.5))
        }
        .buttonStyle(PlainButtonStyle())
        .modifier(ShakeEffect(animatableData: shakeTrigger ? 1 : 0))
        .accessibilityLabel(tag.accessibilityLabel)
        .accessibilityValue(isSelected ? "Seçildi" : "Seçilmedi")
        .accessibilityHint(isSuggested ? "Bu etiket ruh haline göre önerildi. Seçmek veya seçimi kaldırmak için dokun." : "Seçmek veya seçimi kaldırmak için dokun.")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func toggleTag(_ tag: MoodTag) {
        if selectedTags.contains(tag.rawValue) {
            // Deselect
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                selectedTags.remove(tag.rawValue)
            }
        } else {
            // Try to select
            if selectedTags.count >= maxSelectionCount {
                // Show limit exceeded feedback
                HapticManager.shared.tagLimitExceeded()
                triggerShake()
                showToastMessage("En fazla 3 etiket seçebilirsin")
            } else {
                // Select
                HapticManager.shared.tagSelected()
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    selectedTags.insert(tag.rawValue)
                }
            }
        }
    }

    private func triggerShake() {
        shakeTrigger.toggle()
        // Reset after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            shakeTrigger = false
        }
    }

    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true

        // Hide toast after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showToast = false
            }
        }
    }
}

// MARK: - Shake Effect Modifier

/// A view modifier that applies a shake animation
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        // Shake 10 times with decreasing amplitude
        let shakeAmount = sin(animatableData * .pi * 10) * (1 - animatableData) * 8
        return ProjectionTransform(CGAffineTransform(translationX: shakeAmount, y: 0))
    }
}

// MARK: - Preview

#Preview("Tag Chips - No Selection") {
    TagChipsView(selectedTags: .constant([]), selectedMood: nil)
        .padding()
}

#Preview("Tag Chips - Happy Mood Suggestions") {
    TagChipsView(selectedTags: .constant([]), selectedMood: .happy)
        .padding()
}

#Preview("Tag Chips - Sad Mood Suggestions") {
    TagChipsView(selectedTags: .constant([]), selectedMood: .sad)
        .padding()
}

#Preview("Tag Chips - Some Selected") {
    TagChipsView(selectedTags: .constant(["yorgun", "anksiyetik"]), selectedMood: .sad)
        .padding()
}

#Preview("Tag Chips - Max Selected") {
    TagChipsView(selectedTags: .constant(["yorgun", "anksiyetik", "uykusuz"]), selectedMood: .anxious)
        .padding()
}
