import SwiftUI

/// Theme manager for handling app-wide color scheme and theme preferences
@MainActor
final class ThemeManager: ObservableObject {
    /// UserDefaults key for storing theme preference
    private let themePreferenceKey = "app_theme_preference"
    
    /// Current theme preference
    @Published var themePreference: ThemePreference {
        didSet {
            saveThemePreference()
        }
    }
    
    /// Computed color scheme based on preference
    var colorScheme: ColorScheme? {
        switch themePreference {
        case .system:
            return nil // Use system setting
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    /// Shared singleton instance
    static let shared = ThemeManager()
    
    private init() {
        // Load saved preference or default to system
        if let savedValue = UserDefaults.standard.string(forKey: themePreferenceKey),
           let preference = ThemePreference(rawValue: savedValue) {
            self.themePreference = preference
        } else {
            self.themePreference = .system
        }
    }
    
    /// Saves the current theme preference to UserDefaults
    private func saveThemePreference() {
        UserDefaults.standard.set(themePreference.rawValue, forKey: themePreferenceKey)
    }
    
    /// Sets the theme preference
    /// - Parameter preference: The desired theme preference
    func setTheme(_ preference: ThemePreference) {
        themePreference = preference
    }
}

/// Theme preference options
enum ThemePreference: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var id: String { rawValue }
    
    /// Localized display name
    var displayName: String {
        switch self {
        case .system:
            return "Sistem"
        case .light:
            return "Açık"
        case .dark:
            return "Koyu"
        }
    }
    
    /// System icon name
    var iconName: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}

// MARK: - Color Extensions for Dark Mode

extension Color {
    // MARK: - Semantic Colors
    
    /// Background color that adapts to light/dark mode
    /// Light: #F8F9FA, Dark: #1C1C1E
    static var appBackground: Color {
        Color("AppBackground", bundle: nil)
    }
    
    /// Card background color with glassmorphism effect
    /// Light: #FFFFFF, Dark: #2C2C2E
    static var appCardBackground: Color {
        Color("AppCardBackground", bundle: nil)
    }
    
    /// Primary text color
    /// Light: #1A1A2E, Dark: #F5F5F7
    static var appTextPrimary: Color {
        Color("AppTextPrimary", bundle: nil)
    }
    
    /// Secondary text color
    /// Light: #6B7280, Dark: #A1A1AA
    static var appTextSecondary: Color {
        Color("AppTextSecondary", bundle: nil)
    }
    
    /// Border/divider color
    /// Light: #E5E7EB, Dark: #3A3A3C
    static var appBorder: Color {
        Color("AppBorder", bundle: nil)
    }
    
    /// Elevated background for sheets and modals
    /// Light: #FFFFFF, Dark: #2C2C2E
    static var appElevatedBackground: Color {
        Color("AppElevatedBackground", bundle: nil)
    }
}

// MARK: - View Modifier for Theme

struct AppThemeModifier: ViewModifier {
    @StateObject private var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.colorScheme)
    }
}

extension View {
    /// Applies the app's theme preference to the view
    func appTheme() -> some View {
        modifier(AppThemeModifier())
    }
}
