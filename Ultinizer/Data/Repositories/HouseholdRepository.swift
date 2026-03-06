import Foundation

final class HouseholdRepository: HouseholdRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func createHousehold(name: String) async throws -> Household {
        let request = CreateHouseholdRequestDTO(name: name)
        let response: HouseholdDTO = try await apiClient.request(
            endpoint: .createHousehold,
            body: request
        )
        return HouseholdMapper.map(response)
    }

    func joinHousehold(inviteCode: String) async throws -> Household {
        let request = JoinHouseholdRequestDTO(inviteCode: inviteCode)
        let response: HouseholdDTO = try await apiClient.request(
            endpoint: .joinHousehold,
            body: request
        )
        return HouseholdMapper.map(response)
    }

    func getMyHousehold() async throws -> Household {
        let response: HouseholdDTO = try await apiClient.request(endpoint: .myHousehold)
        return HouseholdMapper.map(response)
    }

    func regenerateInviteCode() async throws -> Household {
        let response: HouseholdDTO = try await apiClient.request(endpoint: .regenerateCode)
        return HouseholdMapper.map(response)
    }
}
