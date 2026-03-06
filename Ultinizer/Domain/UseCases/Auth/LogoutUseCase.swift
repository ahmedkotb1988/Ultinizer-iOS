import Foundation

protocol LogoutUseCaseProtocol: Sendable {
    func execute() async throws
}

final class LogoutUseCase: LogoutUseCaseProtocol, @unchecked Sendable {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute() async throws {
        try await authRepository.logout()
    }
}
