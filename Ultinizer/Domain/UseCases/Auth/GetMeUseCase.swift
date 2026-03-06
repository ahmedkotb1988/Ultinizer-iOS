import Foundation

protocol GetMeUseCaseProtocol: Sendable {
    func execute() async throws -> User
}

final class GetMeUseCase: GetMeUseCaseProtocol, @unchecked Sendable {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute() async throws -> User {
        try await authRepository.getMe()
    }
}
