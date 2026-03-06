import Foundation

final class AuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClientProtocol
    private let keychainService: KeychainServiceProtocol

    init(apiClient: APIClientProtocol, keychainService: KeychainServiceProtocol) {
        self.apiClient = apiClient
        self.keychainService = keychainService
    }

    func login(email: String, password: String) async throws -> LoginResult {
        let request = LoginRequestDTO(email: email, password: password)
        let response: LoginResponseDTO = try await apiClient.request(
            endpoint: .login,
            body: request
        )
        try await keychainService.setAccessToken(response.tokens.accessToken)
        try await keychainService.setRefreshToken(response.tokens.refreshToken)
        return LoginResult(
            user: UserMapper.map(response.user),
            tokens: response.tokens,
            household: response.household.map(HouseholdMapper.map)
        )
    }

    func register(input: RegisterInput) async throws -> LoginResult {
        let request = RegisterRequestDTO(
            email: input.email,
            password: input.password,
            displayName: input.displayName,
            roleLabel: input.roleLabel
        )
        let response: LoginResponseDTO = try await apiClient.request(
            endpoint: .register,
            body: request
        )
        try await keychainService.setAccessToken(response.tokens.accessToken)
        try await keychainService.setRefreshToken(response.tokens.refreshToken)
        return LoginResult(
            user: UserMapper.map(response.user),
            tokens: response.tokens,
            household: response.household.map(HouseholdMapper.map)
        )
    }

    func logout() async throws {
        try? await apiClient.request(endpoint: .logout)
        try await keychainService.clearTokens()
    }

    func getMe() async throws -> User {
        let response: MeResponseDTO = try await apiClient.request(endpoint: .me)
        return UserMapper.map(response)
    }

    func updateMe(displayName: String?, roleLabel: String?) async throws -> User {
        let request = UpdateMeRequestDTO(displayName: displayName, roleLabel: roleLabel)
        let response: UserDTO = try await apiClient.request(endpoint: .updateMe, body: request)
        return UserMapper.map(response)
    }

    func uploadAvatar(imageData: Data, fileName: String, mimeType: String) async throws -> String {
        let response: AvatarResponseDTO = try await apiClient.upload(
            endpoint: .uploadAvatar,
            fileData: imageData,
            fileName: fileName,
            mimeType: mimeType,
            fieldName: "file"
        )
        return response.avatarUrl
    }

    func forgotPassword(email: String) async throws {
        let request = ForgotPasswordRequestDTO(email: email)
        try await apiClient.request(endpoint: .forgotPassword, body: request)
    }

    func resetPassword(token: String, password: String) async throws {
        let request = ResetPasswordRequestDTO(token: token, password: password)
        try await apiClient.request(endpoint: .resetPassword, body: request)
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        let request = ChangePasswordRequestDTO(currentPassword: currentPassword, newPassword: newPassword)
        try await apiClient.request(endpoint: .changePassword, body: request)
    }

    func deleteAccount(password: String) async throws {
        let request = DeleteAccountRequestDTO(password: password)
        try await apiClient.request(endpoint: .deleteAccount, body: request)
        try await keychainService.clearTokens()
    }
}
