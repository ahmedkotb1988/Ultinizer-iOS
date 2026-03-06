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
        // Check if biometric is available and enabled
        let context = await BiometricService.shared
        biometricType = await context.biometricTypeString()
    }
}
