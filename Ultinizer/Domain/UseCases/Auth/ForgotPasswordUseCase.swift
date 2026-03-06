import Foundation

protocol ForgotPasswordUseCaseProtocol: Sendable {
    func execute(email: String) async throws
}

final class ForgotPasswordUseCase: ForgotPasswordUseCaseProtocol, @unchecked Sendable {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(email: String) async throws {
        guard !email.isEmpty else {
            throw APIError.unknown("Email is required")
        }
        try await authRepository.forgotPassword(email: email)
    }
}
