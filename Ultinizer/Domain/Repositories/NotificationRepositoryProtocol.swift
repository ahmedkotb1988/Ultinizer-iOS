import Foundation

struct NotificationListResult {
    let notifications: [AppNotification]
    let cursor: String?
    let hasMore: Bool
}

protocol NotificationRepositoryProtocol: Sendable {
    func getNotifications(cursor: String?, limit: Int?) async throws -> NotificationListResult
    func markAsRead(id: String) async throws
    func markAllAsRead() async throws
    func getPreferences() async throws -> NotificationPreferences
    func updatePreferences(_ prefs: NotificationPreferences) async throws -> NotificationPreferences
}
