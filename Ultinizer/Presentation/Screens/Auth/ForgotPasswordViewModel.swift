import Foundation
import Observation

@Observable
final class ForgotPasswordViewModel {
    var email = ""
    var errorMessage = ""
    var isLoading = false
    var isSent = false

    private let forgotPasswordUseCase: ForgotPasswordUseCaseProtocol

    init(forgotPasswordUseCase: ForgotPasswordUseCaseProtocol) {
        self.forgotPasswordUseCase = forgotPasswordUseCase
    }

    var hasError: Bool { !errorMessage.isEmpty }

    @MainActor
    func submit() async {
        guard PasswordValidator.validateEmail(email) else {
            errorMessage = "Please enter a valid email"
            return
        }

        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        do {
            try await forgotPasswordUseCase.execute(email: email)
            isSent = true
        } catch let error as APIError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
    }
}
