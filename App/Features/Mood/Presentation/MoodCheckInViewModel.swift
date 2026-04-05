import SwiftUI
import SwiftData

/// View model for the mood check-in flow
@MainActor
final class MoodCheckInViewModel: ObservableObject {
    @Published var selectedMood: MoodOption?
    @Published var intensity: IntensityLevel = .medium
    @Published var selectedTags: Set<String> = []
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var saveSuccess: Bool = false
    
    private let persistenceService: MoodPersistenceService
    
    var canSave: Bool {
        selectedMood != nil && !isSaving
    }
    
    var hasError: Bool {
        errorMessage != nil
    }
    
    init(persistenceService: MoodPersistenceService) {
        self.persistenceService = persistenceService
    }
    
    /// Saves the current mood entry to SwiftData
    func saveMoodEntry() {
        guard let mood = selectedMood else { return }
        
        isSaving = true
        errorMessage = nil
        showError = false
        saveSuccess = false
        
        Task {
            do {
                let entry = try await persistenceService.saveMoodEntry(
                    moodOption: mood,
                    intensityLevel: intensity,
                    tags: selectedTags
                )
                
                await MainActor.run {
                    self.isSaving = false
                    self.saveSuccess = true
                    
                    // Trigger success haptic after save completes
                    HapticManager.shared.moodSaved()
                    
                    // Reset form after successful save
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        self?.reset()
                    }
                }
                
                print("✅ Mood entry saved: \(entry.emoji) at \(entry.formattedDate)")
                
            } catch let error as MoodPersistenceError {
                await MainActor.run {
                    self.isSaving = false
                    self.errorMessage = error.errorDescription
                    self.showError = true
                }
                
                // Trigger error haptic
                HapticManager.shared.saveFailed()
                
            } catch {
                await MainActor.run {
                    self.isSaving = false
                    self.errorMessage = "Kaydedilemedi. Tekrar dene."
                    self.showError = true
                }
                
                // Trigger error haptic
                HapticManager.shared.saveFailed()
            }
        }
    }
    
    /// Retries the last save operation
    func retrySave() {
        saveMoodEntry()
    }
    
    /// Clears the current error state
    func clearError() {
        errorMessage = nil
        showError = false
    }
    
    func reset() {
        selectedMood = nil
        intensity = .medium
        selectedTags.removeAll()
        errorMessage = nil
        showError = false
        saveSuccess = false
    }
}

// MARK: - Preview Support

extension MoodCheckInViewModel {
    /// Creates a preview view model with in-memory persistence
    static func preview() -> MoodCheckInViewModel {
        MoodCheckInViewModel(persistenceService: MoodPersistenceService.preview())
    }
}
