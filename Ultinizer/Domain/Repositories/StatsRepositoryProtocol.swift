import Foundation

protocol StatsRepositoryProtocol: Sendable {
    func getDashboard() async throws -> DashboardData
    func getOverview() async throws -> StatsOverview
}
