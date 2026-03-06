import XCTest
@testable import Ultinizer

@MainActor
final class LoginViewModelTests: XCTestCase {
    var mockAuthRepo: MockAuthRepository!
    var authManager: AuthManager!
    var sut: LoginViewModel!

    override func setUp() {
        super.setUp()
        mockAuthRepo = MockAuthRepository()
        let mockKeychain = MockKeychainService()
        let mockDefaults = UserDefaultsService(defaults: UserDefaults(suiteName: "test_\(UUID().uuidString)")!)

        let loginUC = LoginUseCase(authRepository: mockAuthRepo)
        let registerUC = RegisterUseCase(authRepository: mockAuthRepo)
        let logoutUC = LogoutUseCase(authRepository: mockAuthRepo)
        let getMeUC = GetMeUseCase(authRepository: mockAuthRepo)

        // We need a mock household repo too
        let mockHouseholdRepo = MockHouseholdRepository()

        authManager = AuthManager(
            loginUseCase: loginUC,
            registerUseCase: registerUC,
            logoutUseCase: logoutUC,
            getMeUseCase: getMeUC,
            householdRepository: mockHouseholdRepo,
            keychainService: mockKeychain,
            userDefaultsService: mockDefaults
        )

        sut = LoginViewModel(authManager: authManager)
    }

    func testLoginEmptyEmail() async {
        sut.email = ""
        sut.password = "password123"
        let result = await sut.login()
        XCTAssertNil(result)
        XCTAssertEqual(sut.errorMessage, "Email is required")
    }

    func testLoginEmptyPassword() async {
        sut.email = "test@example.com"
        sut.password = ""
        let result = await sut.login()
        XCTAssertNil(result)
        XCTAssertEqual(sut.errorMessage, "Password is required")
    }

    func testLoginSuccess() async {
        let user = makeTestUser()
        let tokens = TokenPairDTO(accessToken: "at", refreshToken: "rt")
        mockAuthRepo.loginResult = LoginResult(user: user, tokens: tokens, household: makeTestHousehold())

        sut.email = "test@example.com"
        sut.password = "password123"

        let result = await sut.login()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.user.id, user.id)
        XCTAssertTrue(sut.errorMessage.isEmpty)
    }

    func testLoginFailure() async {
        mockAuthRepo.loginError = APIError.invalidCredentials

        sut.email = "test@example.com"
        sut.password = "wrong"

        let result = await sut.login()
        XCTAssertNil(result)
        XCTAssertFalse(sut.errorMessage.isEmpty)
    }
}

// Additional mock for tests
final class MockHouseholdRepository: HouseholdRepositoryProtocol, @unchecked Sendable {
    func createHousehold(name: String) async throws -> Household { makeTestHousehold() }
    func joinHousehold(inviteCode: String) async throws -> Household { makeTestHousehold() }
    func getMyHousehold() async throws -> Household { makeTestHousehold() }
    func regenerateInviteCode() async throws -> Household { makeTestHousehold() }
}
