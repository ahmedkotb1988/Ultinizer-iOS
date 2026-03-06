import Foundation

final class StatsRepository: StatsRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func getDashboard() async throws -> DashboardData {
        let dto: DashboardStatsDTO = try await apiClient.request(endpoint: .dashboardStats)
        return StatsMapper.mapDashboard(dto)
    }

    func getOverview() async throws -> StatsOverview {
        let dto: StatsOverviewDTO = try await apiClient.request(endpoint: .overviewStats)
        return StatsMapper.mapOverview(dto)
    }
}
