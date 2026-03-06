import Foundation

protocol UserDefaultsServiceProtocol: Sendable {
    func getBool(forKey key: String) -> Bool
    func setBool(_ value: Bool, forKey key: String)
    func getString(forKey key: String) -> String?
    func setString(_ value: String?, forKey key: String)
    func getData(forKey key: String) -> Data?
    func setData(_ value: Data?, forKey key: String)
    func remove(forKey key: String)
}

final class UserDefaultsService: UserDefaultsServiceProtocol, @unchecked Sendable {
    private let defaults: UserDefaults

    enum Keys {
        static let biometricEnabled = "biometric_enabled"
        static let themeMode = "app_theme_mode"
        static let cachedUser = "cached_user"
        static let onboardingCompleted = "onboarding_completed"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func getBool(forKey key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    func setBool(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func getString(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }

    func setString(_ value: String?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func getData(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func setData(_ value: Data?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}
