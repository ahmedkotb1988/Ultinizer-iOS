import Foundation

protocol LoginUseCaseProtocol: Sendable {
    func execute(email: String, password: String) async throws -> LoginResult
}

final class LoginUseCase: LoginUseCaseProtocol, @unchecked Sendable {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String) async throws -> LoginResult {
        guard !email.isEmpty else {
            throw APIError.unknown("Email is required")
        }
        guard !password.isEmpty else {
            throw APIError.unknown("Password is required")
        }
        return try await authRepository.login(email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), password: password)
    }
}
