import Foundation
import Observation
import UIKit

@Observable
final class LoginViewModel {
    var email = ""
    var password = ""
    var errorMessage = ""
    var isLoading = false
    var biometricType: String?

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    var hasError: Bool { !errorMessage.isEmpty }

    /// Whether the login screen should show the biometric button (biometric available AND enabled, or awaiting biometric)
    var showBiometricButton: Bool {
        biometricType != nil && authManager.awaitingBiometric
    }

    @MainActor
    func login() async -> LoginResult? {
        guard !email.isEmpty else {
            errorMessage = "Email is required"
            return nil
        }
        guard !password.isEmpty else {
            errorMessage = "Password is required"
            return nil
        }

        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await authManager.login(email: email, password: password)
            return result
        } catch let error as APIError {
            errorMessage = error.userMessage
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return nil
        } catch {
            errorMessage = "Login failed. Please try again."
            return nil
        }
    }

    func checkBiometric() async {
        let service = BiometricService.shared
        biometricType = await service.biometricTypeString()
    }

    @MainActor
    func authenticateWithBiometric() async {
        guard authManager.awaitingBiometric else { return }

        let service = BiometricService.shared
        let success = await service.authenticate()

        if success {
            await authManager.completeBiometricLogin()
        } else {
            // Biometric failed or cancelled — stay on login screen for manual login
            errorMessage = ""
        }
    }
}
