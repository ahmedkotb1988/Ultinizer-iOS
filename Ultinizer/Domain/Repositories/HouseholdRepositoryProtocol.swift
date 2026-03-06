import Foundation

protocol HouseholdRepositoryProtocol: Sendable {
    func createHousehold(name: String) async throws -> Household
    func joinHousehold(inviteCode: String) async throws -> Household
    func getMyHousehold() async throws -> Household
    func regenerateInviteCode() async throws -> Household
}
