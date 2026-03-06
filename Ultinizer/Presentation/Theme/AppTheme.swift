import SwiftUI

// MARK: - Theme Environment Key

enum AppThemeMode: String, CaseIterable {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@Observable
final class ThemeManager {
    var mode: AppThemeMode = .system

    var preferredColorScheme: ColorScheme? {
        mode.colorScheme
    }

    init() {
        if let saved = UserDefaults.standard.string(forKey: "app_theme_mode"),
           let mode = AppThemeMode(rawValue: saved) {
            self.mode = mode
        }
    }

    func setMode(_ newMode: AppThemeMode) {
        mode = newMode
        UserDefaults.standard.set(newMode.rawValue, forKey: "app_theme_mode")
    }
}

// MARK: - Environment Key

private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
