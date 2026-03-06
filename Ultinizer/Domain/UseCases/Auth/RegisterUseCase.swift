import Foundation

protocol RegisterUseCaseProtocol: Sendable {
    func execute(input: RegisterInput) async throws -> LoginResult
}

final class RegisterUseCase: RegisterUseCaseProtocol, @unchecked Sendable {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(input: RegisterInput) async throws -> LoginResult {
        guard !input.email.isEmpty else {
            throw APIError.unknown("Email is required")
        }
        guard input.password.count >= 8 else {
            throw APIError.unknown("Password must be at least 8 characters")
        }
        guard !input.displayName.isEmpty else {
            throw APIError.unknown("Display name is required")
        }
        let normalizedInput = RegisterInput(
            email: input.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            password: input.password,
            displayName: input.displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            roleLabel: input.roleLabel?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        return try await authRepository.register(input: normalizedInput)
    }
}
