import XCTest
@testable import Ultinizer

final class UserMapperTests: XCTestCase {
    func testMapUserDTO() {
        let dto = UserDTO(
            id: "u1",
            email: "test@example.com",
            displayName: "Test User",
            avatarUrl: "/uploads/avatar.jpg",
            roleLabel: "Admin",
            householdId: "hh1",
            createdAt: Date(),
            updatedAt: Date()
        )

        let user = UserMapper.map(dto)

        XCTAssertEqual(user.id, "u1")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.displayName, "Test User")
        XCTAssertEqual(user.avatarUrl, "/uploads/avatar.jpg")
        XCTAssertEqual(user.roleLabel, "Admin")
        XCTAssertEqual(user.householdId, "hh1")
    }

    func testMapUserDTONilRoleLabel() {
        let dto = UserDTO(
            id: "u1",
            email: "test@example.com",
            displayName: "Test",
            avatarUrl: nil,
            roleLabel: nil,
            householdId: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        let user = UserMapper.map(dto)
        XCTAssertEqual(user.roleLabel, "")
        XCTAssertNil(user.avatarUrl)
        XCTAssertNil(user.householdId)
    }

    func testMapHouseholdDTO() {
        let memberDTO = UserDTO(
            id: "u1", email: "a@b.com", displayName: "A",
            avatarUrl: nil, roleLabel: nil, householdId: "hh1",
            createdAt: Date(), updatedAt: Date()
        )

        let dto = HouseholdDTO(
            id: "hh1",
            name: "Test Home",
            inviteCode: "ABC123",
            createdAt: Date(),
            updatedAt: Date(),
            members: [memberDTO]
        )

        let household = HouseholdMapper.map(dto)
        XCTAssertEqual(household.id, "hh1")
        XCTAssertEqual(household.name, "Test Home")
        XCTAssertEqual(household.inviteCode, "ABC123")
        XCTAssertEqual(household.members.count, 1)
        XCTAssertEqual(household.members.first?.displayName, "A")
    }
}
