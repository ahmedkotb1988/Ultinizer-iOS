import Foundation

protocol DeleteAccountUseCaseProtocol: Sendable {
    func execute(password: String) async throws
}

final class DeleteAccountUseCase: DeleteAccountUseCaseProtocol, @unchecked Sendable {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(password: String) async throws {
        try await authRepository.deleteAccount(password: password)
    }
}
