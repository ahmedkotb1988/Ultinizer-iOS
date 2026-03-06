import Foundation
import Observation

@Observable
final class StatisticsViewModel {
    var stats: StatsOverview?
    var isLoading = false
    var errorMessage = ""

    private let statsRepository: StatsRepositoryProtocol

    init(statsRepository: StatsRepositoryProtocol) {
        self.statsRepository = statsRepository
    }

    @MainActor
    func loadStats() async {
        isLoading = true
        defer { isLoading = false }

        do {
            stats = try await statsRepository.getOverview()
        } catch {
            errorMessage = "Failed to load statistics"
        }
    }
}
