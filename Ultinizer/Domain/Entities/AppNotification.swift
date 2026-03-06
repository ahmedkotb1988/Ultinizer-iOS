import Foundation

struct AppNotification: Identifiable, Equatable, Hashable {
    let id: String
    let userId: String
    let type: NotificationType
    let title: String
    let body: String
    let taskId: String?
    let commentId: String?
    let isRead: Bool
    let createdAt: Date
}

enum NotificationType: String, Codable, Hashable {
    case taskAssigned = "task_assigned"
    case taskDueSoon = "task_due_soon"
    case taskOverdue = "task_overdue"
    case taskComment = "task_comment"
    case taskMention = "task_mention"
    case taskCompleted = "task_completed"
    case recurringReminder = "recurring_reminder"
}

struct NotificationPreferences: Equatable {
    let userId: String
    var quietHoursStart: String?
    var quietHoursEnd: String?
    var categoryMutes: [String]
    var typeMutes: [String]
    var dueSoonMinutes: Int
}
