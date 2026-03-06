import XCTest
@testable import Ultinizer

final class LoginUseCaseTests: XCTestCase {
    var mockRepo: MockAuthRepository!
    var sut: LoginUseCase!

    override func setUp() {
        super.setUp()
        mockRepo = MockAuthRepository()
        sut = LoginUseCase(authRepository: mockRepo)
    }

    func testLoginSuccess() async throws {
        let expectedUser = makeTestUser()
        let tokens = TokenPairDTO(accessToken: "at", refreshToken: "rt")
        mockRepo.loginResult = LoginResult(user: expectedUser, tokens: tokens, household: makeTestHousehold())

        let result = try await sut.execute(email: "test@example.com", password: "password123")
        XCTAssertEqual(result.user.id, expectedUser.id)
        XCTAssertNotNil(result.household)
    }

    func testLoginEmptyEmail() async {
        do {
            _ = try await sut.execute(email: "", password: "password123")
            XCTFail("Expected error")
        } catch {
            // Expected
        }
    }

    func testLoginEmptyPassword() async {
        do {
            _ = try await sut.execute(email: "test@example.com", password: "")
            XCTFail("Expected error")
        } catch {
            // Expected
        }
    }

    func testLoginInvalidCredentials() async {
        mockRepo.loginError = APIError.invalidCredentials

        do {
            _ = try await sut.execute(email: "test@example.com", password: "wrong")
            XCTFail("Expected error")
        } catch let error as APIError {
            XCTAssertEqual(error, .invalidCredentials)
        } catch {
            XCTFail("Wrong error type")
        }
    }
}
