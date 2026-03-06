import Foundation

final class ReportRepository: ReportRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func createReport(
        targetType: ReportTargetType,
        targetId: String,
        reason: ReportReason,
        description: String?
    ) async throws {
        let request = ReportRequestDTO(
            targetType: targetType.rawValue,
            targetId: targetId,
            reason: reason.rawValue,
            description: description
        )
        try await apiClient.request(endpoint: .createReport, body: request)
    }
}
