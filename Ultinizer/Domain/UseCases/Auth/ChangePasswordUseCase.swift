import Foundation

protocol ChangePasswordUseCaseProtocol: Sendable {
    func execute(currentPassword: String, newPassword: String) async throws
}

final class ChangePasswordUseCase: ChangePasswordUseCaseProtocol, @unchecked Sendable {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(currentPassword: String, newPassword: String) async throws {
        guard !currentPassword.isEmpty else {
            throw APIError.unknown("Current password is required")
        }
        guard newPassword.count >= 8 else {
            throw APIError.unknown("New password must be at least 8 characters")
        }
        guard currentPassword != newPassword else {
            throw APIError.samePassword
        }
        try await authRepository.changePassword(currentPassword: currentPassword, newPassword: newPassword)
    }
}
