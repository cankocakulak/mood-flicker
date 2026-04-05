import SwiftUI
import SwiftData

/// Main view for the mood check-in flow
struct MoodCheckInView: View {
    @StateObject private var viewModel: MoodCheckInViewModel
    @Environment(\.modelContext) private var modelContext
    
    /// Preselected mood emoji from widget deep link
    @Binding var preselectedMoodEmoji: String?
    
    init(preselectedMoodEmoji: Binding<String?> = .constant(nil)) {
        // Initialize with a placeholder - will be properly set in onAppear
        _viewModel = StateObject(wrappedValue: MoodCheckInViewModel.preview())
        _preselectedMoodEmoji = preselectedMoodEmoji
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                headerSection
                
                // Emoji Grid
                emojiGridSection
                
                // Intensity Slider (appears after emoji selection)
                intensitySliderSection
                
                // Tag Chips (appears after emoji selection)
                tagChipsSection
                
                // Error Message
                errorSection
                
                // Save Button (appears after emoji selection)
                saveButtonSection
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Ruh Hali")
        .navigationBarTitleDisplayMode(.large)
        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedMood)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showError)
        .onAppear {
            setupViewModel()
        }
    }
    
    private func setupViewModel() {
        // Create persistence service from the environment's model context
        if let container = modelContext.container {
            let persistenceService = MoodPersistenceService(modelContainer: container)
            viewModel = MoodCheckInViewModel(persistenceService: persistenceService)
            
            // Handle preselected mood from widget
            if let emoji = preselectedMoodEmoji,
               let moodOption = MoodOption(rawValue: emoji) {
                viewModel.selectedMood = moodOption
                // Clear the binding after handling
                preselectedMoodEmoji = nil
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("Bugün kendini nasıl hissediyorsun?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Bir emoji seçerek başla")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, AppTheme.Spacing.lg)
        .accessibilityElement(children: .combine)
    }
    
    private var emojiGridSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            EmojiGridView(selectedMood: $viewModel.selectedMood)
                .padding(.horizontal)
            
            if let selectedMood = viewModel.selectedMood {
                Text(selectedMood.accessibilityLabel)
                    .font(.headline)
                    .foregroundStyle(selectedMood.moodColor)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedMood)
    }
    
    private var intensitySliderSection: some View {
        Group {
            if let selectedMood = viewModel.selectedMood {
                IntensitySliderView(
                    intensity: $viewModel.intensity,
                    moodColor: selectedMood.moodColor
                )
                .padding(.horizontal)
                .transition(
                    .opacity
                    .combined(with: .move(edge: .bottom))
                )
            }
        }
    }
    
    private var tagChipsSection: some View {
        Group {
            if viewModel.selectedMood != nil {
                TagChipsView(
                    selectedTags: $viewModel.selectedTags,
                    selectedMood: viewModel.selectedMood
                )
                .padding(.horizontal)
                .transition(
                    .opacity
                    .combined(with: .move(edge: .bottom))
                )
            }
        }
    }
    
    private var errorSection: some View {
        Group {
            if viewModel.showError, let errorMessage = viewModel.errorMessage {
                VStack(spacing: AppTheme.Spacing.sm) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                        
                        Spacer()
                    }
                    
                    // Retry button
                    Button(action: {
                        viewModel.retrySave()
                    }) {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "arrow.clockwise")
                            Text("Tekrar Dene")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.red)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card)
                        .fill(Color.red.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card)
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
                .transition(
                    .opacity
                    .combined(with: .move(edge: .top))
                )
            }
        }
    }
    
    private var saveButtonSection: some View {
        Group {
            if viewModel.selectedMood != nil {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Button(action: {
                        viewModel.saveMoodEntry()
                    }) {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            if viewModel.isSaving {
                                ProgressView()
                                    .tint(.white)
                            }
                            
                            if viewModel.saveSuccess {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                            }
                            
                            Text(viewModel.saveSuccess ? "Kaydedildi" : "Kaydet")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card)
                                .fill(
                                    viewModel.saveSuccess
                                    ? Color.green
                                    : (viewModel.selectedMood?.moodColor ?? .accentColor)
                                )
                        )
                    }
                    .disabled(viewModel.isSaving || viewModel.saveSuccess)
                    .padding(.horizontal)
                    
                    // Sync indicator
                    if viewModel.isSaving {
                        Text("Kaydediliyor...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                    }
                }
                .padding(.top, AppTheme.Spacing.md)
                .transition(
                    .opacity
                    .combined(with: .move(edge: .bottom))
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("Mood Check-In") {
    NavigationStack {
        MoodCheckInView(preselectedMoodEmoji: .constant(nil))
    }
    .modelContainer(for: MoodEntry.self, inMemory: true)
}

#Preview("Mood Check-In with Error") {
    let viewModel = MoodCheckInViewModel.preview()
    viewModel.selectedMood = .happy
    viewModel.errorMessage = "Kaydedilemedi. Tekrar dene."
    viewModel.showError = true
    
    return NavigationStack {
        MoodCheckInView(preselectedMoodEmoji: .constant(nil))
    }
    .modelContainer(for: MoodEntry.self, inMemory: true)
}
