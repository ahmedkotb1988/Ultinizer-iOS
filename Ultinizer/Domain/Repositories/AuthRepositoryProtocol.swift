import Foundation

struct LoginResult {
    let user: User
    let tokens: TokenPairDTO
    let household: Household?
}

struct RegisterInput {
    let email: String
    let password: String
    let displayName: String
    let roleLabel: String?
}

protocol AuthRepositoryProtocol: Sendable {
    func login(email: String, password: String) async throws -> LoginResult
    func register(input: RegisterInput) async throws -> LoginResult
    func logout() async throws
    func getMe() async throws -> User
    func updateMe(displayName: String?, roleLabel: String?) async throws -> User
    func uploadAvatar(imageData: Data, fileName: String, mimeType: String) async throws -> String
    func forgotPassword(email: String) async throws
    func resetPassword(token: String, password: String) async throws
    func changePassword(currentPassword: String, newPassword: String) async throws
    func deleteAccount(password: String) async throws
}
