import Foundation

final class NotificationRepository: NotificationRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func getNotifications(cursor: String?, limit: Int?) async throws -> NotificationListResult {
        var queryItems: [URLQueryItem] = []
        if let cursor { queryItems.append(.init(name: "cursor", value: cursor)) }
        if let limit { queryItems.append(.init(name: "limit", value: String(limit))) }

        let dtos: [NotificationDTO] = try await apiClient.request(
            endpoint: .notifications,
            queryItems: queryItems.isEmpty ? nil : queryItems
        )
        return NotificationListResult(
            notifications: dtos.map(NotificationMapper.map),
            cursor: nil,
            hasMore: false
        )
    }

    func markAsRead(id: String) async throws {
        try await apiClient.request(endpoint: .markNotificationRead(id: id))
    }

    func markAllAsRead() async throws {
        try await apiClient.request(endpoint: .markAllNotificationsRead)
    }

    func getPreferences() async throws -> NotificationPreferences {
        let dto: NotificationPreferencesDTO = try await apiClient.request(endpoint: .notificationPreferences)
        return NotificationPreferences(
            userId: dto.userId ?? "",
            quietHoursStart: dto.quietHoursStart,
            quietHoursEnd: dto.quietHoursEnd,
            categoryMutes: dto.categoryMutes ?? [],
            typeMutes: dto.typeMutes ?? [],
            dueSoonMinutes: dto.dueSoonMinutes ?? 30
        )
    }

    func updatePreferences(_ prefs: NotificationPreferences) async throws -> NotificationPreferences {
        let request = NotificationPreferencesDTO(
            userId: nil,
            quietHoursStart: prefs.quietHoursStart,
            quietHoursEnd: prefs.quietHoursEnd,
            categoryMutes: prefs.categoryMutes,
            typeMutes: prefs.typeMutes,
            dueSoonMinutes: prefs.dueSoonMinutes
        )
        let dto: NotificationPreferencesDTO = try await apiClient.request(
            endpoint: .notificationPreferences,
            body: request
        )
        return NotificationPreferences(
            userId: dto.userId ?? prefs.userId,
            quietHoursStart: dto.quietHoursStart,
            quietHoursEnd: dto.quietHoursEnd,
            categoryMutes: dto.categoryMutes ?? [],
            typeMutes: dto.typeMutes ?? [],
            dueSoonMinutes: dto.dueSoonMinutes ?? 30
        )
    }
}
