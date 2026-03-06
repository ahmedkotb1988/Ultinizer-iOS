import Foundation
import Observation
import UIKit

@Observable
final class RegisterViewModel {
    var displayName = ""
    var email = ""
    var password = ""
    var roleLabel = ""
    var errorMessage = ""
    var isLoading = false

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    var hasError: Bool { !errorMessage.isEmpty }

    @MainActor
    func register() async -> Bool {
        guard !displayName.isEmpty else {
            errorMessage = "Display name is required"
            return false
        }
        guard PasswordValidator.validateEmail(email) else {
            errorMessage = "Please enter a valid email"
            return false
        }
        let validation = PasswordValidator.validate(password)
        guard validation.isValid else {
            errorMessage = validation.errors.first ?? "Invalid password"
            return false
        }

        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        do {
            let input = RegisterInput(
                email: email,
                password: password,
                displayName: displayName,
                roleLabel: roleLabel.isEmpty ? nil : roleLabel
            )
            _ = try await authManager.register(input: input)
            return true
        } catch let error as APIError {
            errorMessage = error.userMessage
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return false
        } catch {
            errorMessage = "Registration failed. Please try again."
            return false
        }
    }
}
