import XCTest
@testable import Ultinizer

final class AuthRepositoryTests: XCTestCase {
    var mockAPIClient: MockAPIClient!
    var mockKeychain: MockKeychainService!
    var sut: AuthRepository!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockKeychain = MockKeychainService()
        sut = AuthRepository(apiClient: mockAPIClient, keychainService: mockKeychain)
    }

    func testLoginStoresTokens() async throws {
        let responseDTO = LoginResponseDTO(
            user: UserDTO(
                id: "u1", email: "test@example.com", displayName: "Test",
                avatarUrl: nil, roleLabel: nil, householdId: nil,
                createdAt: Date(), updatedAt: Date()
            ),
            tokens: TokenPairDTO(accessToken: "access123", refreshToken: "refresh456"),
            household: nil
        )

        mockAPIClient.requestHandler = { endpoint, body, query in
            return responseDTO
        }

        let result = try await sut.login(email: "test@example.com", password: "password123")

        XCTAssertEqual(result.user.email, "test@example.com")

        let storedAccess = try await mockKeychain.getAccessToken()
        let storedRefresh = try await mockKeychain.getRefreshToken()
        XCTAssertEqual(storedAccess, "access123")
        XCTAssertEqual(storedRefresh, "refresh456")
    }

    func testLogoutClearsTokens() async throws {
       try await mockKeychain.setAccessToken("token")
       try await mockKeychain.setRefreshToken("refresh")

        mockAPIClient.requestHandler = { _, _, _ in EmptyData() }

        try await sut.logout()

        let storedAccess = try await mockKeychain.getAccessToken()
        XCTAssertNil(storedAccess)
    }

    // Helper to set token for keychain mock
    private func setToken(_ token: String) async {
        try? await mockKeychain.setAccessToken(token)
    }
}
