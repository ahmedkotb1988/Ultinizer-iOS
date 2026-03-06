import XCTest
@testable import Ultinizer

final class PasswordValidatorTests: XCTestCase {
    func testValidPassword() {
        let result = PasswordValidator.validate("password123")
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.errors.isEmpty)
    }

    func testShortPassword() {
        let result = PasswordValidator.validate("short")
        XCTAssertFalse(result.isValid)
        XCTAssertFalse(result.errors.isEmpty)
    }

    func testEmptyPassword() {
        let result = PasswordValidator.validate("")
        XCTAssertFalse(result.isValid)
    }

    func testExactly8Characters() {
        let result = PasswordValidator.validate("12345678")
        XCTAssertTrue(result.isValid)
    }

    func testValidEmail() {
        XCTAssertTrue(PasswordValidator.validateEmail("test@example.com"))
        XCTAssertTrue(PasswordValidator.validateEmail("user.name@domain.co"))
    }

    func testInvalidEmail() {
        XCTAssertFalse(PasswordValidator.validateEmail(""))
        XCTAssertFalse(PasswordValidator.validateEmail("notanemail"))
        XCTAssertFalse(PasswordValidator.validateEmail("@nodomain"))
        XCTAssertFalse(PasswordValidator.validateEmail("user@"))
    }
}
