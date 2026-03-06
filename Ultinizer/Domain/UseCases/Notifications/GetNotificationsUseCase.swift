import Foundation

protocol GetNotificationsUseCaseProtocol: Sendable {
    func execute(cursor: String?, limit: Int?) async throws -> NotificationListResult
}

final class GetNotificationsUseCase: GetNotificationsUseCaseProtocol, @unchecked Sendable {
    private let notificationRepository: NotificationRepositoryProtocol

    init(notificationRepository: NotificationRepositoryProtocol) {
        self.notificationRepository = notificationRepository
    }

    func execute(cursor: String? = nil, limit: Int? = nil) async throws -> NotificationListResult {
        try await notificationRepository.getNotifications(cursor: cursor, limit: limit)
    }
}
