import Foundation

protocol UpdateProfileUseCaseProtocol: Sendable {
    func execute(displayName: String?, roleLabel: String?) async throws -> User
}

final class UpdateProfileUseCase: UpdateProfileUseCaseProtocol, @unchecked Sendable {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(displayName: String?, roleLabel: String?) async throws -> User {
        if let name = displayName, name.isEmpty {
            throw APIError.unknown("Display name cannot be empty")
        }
        return try await authRepository.updateMe(displayName: displayName, roleLabel: roleLabel)
    }
}
