import SwiftUI
import UIKit

/// Centralized haptic feedback manager that respects accessibility settings
/// Provides comprehensive haptic feedback throughout the app
@MainActor
final class HapticManager {
    static let shared = HapticManager()

    // MARK: - Feedback Generators

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    // MARK: - State

    private var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    // MARK: - Initialization

    private init() {
        prepareGenerators()

        // Listen for accessibility changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilitySettingsChanged),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Preparation

    /// Prepares all generators for immediate feedback
    func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selection.prepare()
        notification.prepare()
    }

    @objc private func accessibilitySettingsChanged() {
        // Re-prepare generators when accessibility settings change
        if !isReduceMotionEnabled {
            prepareGenerators()
        }
    }

    // MARK: - Impact Feedback

    /// Light impact feedback for emoji selection and light interactions
    /// - Parameter intensity: Optional intensity override (0.0 to 1.0)
    func impactLight(intensity: CGFloat = 1.0) {
        guard !isReduceMotionEnabled else { return }
        impactLight.impactOccurred(intensity: intensity)
    }

    /// Medium impact feedback for moderate interactions
    /// - Parameter intensity: Optional intensity override (0.0 to 1.0)
    func impactMedium(intensity: CGFloat = 1.0) {
        guard !isReduceMotionEnabled else { return }
        impactMedium.impactOccurred(intensity: intensity)
    }

    /// Heavy impact feedback for strong interactions
    /// - Parameter intensity: Optional intensity override (0.0 to 1.0)
    func impactHeavy(intensity: CGFloat = 1.0) {
        guard !isReduceMotionEnabled else { return }
        impactHeavy.impactOccurred(intensity: intensity)
    }

    /// Generic impact feedback with style selection
    /// - Parameters:
    ///   - style: The feedback style (light, medium, heavy, soft, rigid)
    ///   - intensity: Optional intensity override (0.0 to 1.0)
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1.0) {
        guard !isReduceMotionEnabled else { return }

        switch style {
        case .light:
            impactLight.impactOccurred(intensity: intensity)
        case .medium:
            impactMedium.impactOccurred(intensity: intensity)
        case .heavy:
            impactHeavy.impactOccurred(intensity: intensity)
        case .soft:
            let soft = UIImpactFeedbackGenerator(style: .soft)
            soft.prepare()
            soft.impactOccurred(intensity: intensity)
        case .rigid:
            let rigid = UIImpactFeedbackGenerator(style: .rigid)
            rigid.prepare()
            rigid.impactOccurred(intensity: intensity)
        @unknown default:
            impactLight.impactOccurred(intensity: intensity)
        }
    }

    // MARK: - Selection Feedback

    /// Selection changed feedback for slider and picker interactions
    func selectionChanged() {
        guard !isReduceMotionEnabled else { return }
        selection.selectionChanged()
    }

    // MARK: - Notification Feedback

    /// Success notification feedback for completed operations
    func success() {
        guard !isReduceMotionEnabled else { return }
        notification.notificationOccurred(.success)
    }

    /// Error notification feedback for failures and limit exceeded
    func error() {
        guard !isReduceMotionEnabled else { return }
        notification.notificationOccurred(.error)
    }

    /// Warning notification feedback for cautions
    func warning() {
        guard !isReduceMotionEnabled else { return }
        notification.notificationOccurred(.warning)
    }

    /// Generic notification feedback
    /// - Parameter type: The notification type (success, error, warning)
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard !isReduceMotionEnabled else { return }
        notification.notificationOccurred(type)
    }

    // MARK: - Convenience Methods for App-Specific Interactions

    /// Haptic feedback for emoji selection in mood check-in
    func emojiSelected() {
        impactLight(intensity: 0.8)
    }

    /// Haptic feedback for intensity slider value changes
    func intensityChanged() {
        selectionChanged()
    }

    /// Haptic feedback for tag selection
    func tagSelected() {
        impactLight(intensity: 0.5)
    }

    /// Haptic feedback for tag limit exceeded
    func tagLimitExceeded() {
        error()
    }

    /// Haptic feedback for successful mood save
    func moodSaved() {
        success()
    }

    /// Haptic feedback for save failure
    func saveFailed() {
        error()
    }

    /// Haptic feedback for button taps
    func buttonTapped() {
        impactLight(intensity: 0.6)
    }

    /// Haptic feedback for navigation transitions
    func navigationChanged() {
        impactLight(intensity: 0.4)
    }
}

// MARK: - SwiftUI View Extension

extension View {
    /// Adds haptic feedback on tap gesture
    /// - Parameter style: The haptic style to use
    /// - Returns: A view with haptic feedback on tap
    func hapticOnTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        onTapGesture {
            HapticManager.shared.impact(style: style)
        }
    }

    /// Adds haptic feedback on long press gesture
    /// - Parameter style: The haptic style to use
    /// - Returns: A view with haptic feedback on long press
    func hapticOnLongPress(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        onLongPressGesture {
            HapticManager.shared.impact(style: style)
        }
    }
}

// MARK: - Preview Helpers

#if DEBUG
    extension HapticManager {
        /// Preview instance that bypasses reduce motion check
        static var preview: HapticManager {
            // Return the shared instance for preview - haptics won't work in preview anyway
            .shared
        }
    }
#endif
