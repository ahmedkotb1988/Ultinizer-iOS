import Foundation

enum APIEndpoint {
    // Auth
    case login
    case register
    case refreshToken
    case logout
    case me
    case updateMe
    case uploadAvatar

    // Password
    case forgotPassword
    case resetPassword
    case changePassword

    // Households
    case createHousehold
    case joinHousehold
    case myHousehold
    case regenerateCode

    // Tasks
    case getTasks
    case createTask
    case task(id: String)
    case updateTask(id: String)
    case deleteTask(id: String)
    case reorderTasks
    case taskTemplates

    // Subtasks
    case getSubtasks(taskId: String)
    case createSubtask(taskId: String)
    case subtask(taskId: String, subtaskId: String)
    case deleteSubtask(taskId: String, subtaskId: String)

    // Comments
    case getComments(taskId: String)
    case createComment(taskId: String)
    case comment(taskId: String, commentId: String)
    case deleteComment(taskId: String, commentId: String)
    case markCommentSeen(taskId: String, commentId: String)

    // Categories
    case getCategories
    case createCategory
    case category(id: String)

    // Attachments
    case uploadAttachment(taskId: String)
    case deleteAttachment(id: String)

    // Notifications
    case notifications
    case markNotificationRead(id: String)
    case markAllNotificationsRead
    case notificationPreferences

    // Stats
    case dashboardStats
    case overviewStats

    // Reports
    case createReport

    // Account
    case deleteAccount

    // Feed
    case feedToken
    case generateFeedToken
    case revokeFeedToken

    // Push Notifications
    case registerDevice
    case unregisterDevice

    var path: String {
        switch self {
        // Auth
        case .login: return "/api/auth/login"
        case .register: return "/api/auth/register"
        case .refreshToken: return "/api/auth/refresh"
        case .logout: return "/api/auth/logout"
        case .me: return "/api/auth/me"
        case .updateMe: return "/api/auth/me"
        case .uploadAvatar: return "/api/auth/me/avatar"

        // Password
        case .forgotPassword: return "/api/auth/forgot-password"
        case .resetPassword: return "/api/auth/reset-password"
        case .changePassword: return "/api/auth/change-password"

        // Households
        case .createHousehold: return "/api/households"
        case .joinHousehold: return "/api/households/join"
        case .myHousehold: return "/api/households/me"
        case .regenerateCode: return "/api/households/me/regenerate-code"

        // Tasks
        case .getTasks: return "/api/tasks"
        case .createTask: return "/api/tasks"
        case .task(let id): return "/api/tasks/\(id)"
        case .updateTask(let id): return "/api/tasks/\(id)"
        case .deleteTask(let id): return "/api/tasks/\(id)"
        case .reorderTasks: return "/api/tasks/reorder"
        case .taskTemplates: return "/api/tasks/templates"

        // Subtasks
        case .getSubtasks(let taskId): return "/api/tasks/\(taskId)/subtasks"
        case .createSubtask(let taskId): return "/api/tasks/\(taskId)/subtasks"
        case .subtask(let taskId, let subtaskId): return "/api/tasks/\(taskId)/subtasks/\(subtaskId)"
        case .deleteSubtask(let taskId, let subtaskId): return "/api/tasks/\(taskId)/subtasks/\(subtaskId)"

        // Comments
        case .getComments(let taskId): return "/api/tasks/\(taskId)/comments"
        case .createComment(let taskId): return "/api/tasks/\(taskId)/comments"
        case .comment(let taskId, let commentId): return "/api/tasks/\(taskId)/comments/\(commentId)"
        case .deleteComment(let taskId, let commentId): return "/api/tasks/\(taskId)/comments/\(commentId)"
        case .markCommentSeen(let taskId, let commentId): return "/api/tasks/\(taskId)/comments/\(commentId)/seen"

        // Categories
        case .getCategories: return "/api/categories"
        case .createCategory: return "/api/categories"
        case .category(let id): return "/api/categories/\(id)"

        // Attachments
        case .uploadAttachment(let taskId): return "/api/tasks/\(taskId)/attachments"
        case .deleteAttachment(let id): return "/api/attachments/\(id)"

        // Notifications
        case .notifications: return "/api/notifications"
        case .markNotificationRead(let id): return "/api/notifications/\(id)/read"
        case .markAllNotificationsRead: return "/api/notifications/read-all"
        case .notificationPreferences: return "/api/notifications/preferences"

        // Stats
        case .dashboardStats: return "/api/stats/dashboard"
        case .overviewStats: return "/api/stats/overview"

        // Reports
        case .createReport: return "/api/reports"

        // Account
        case .deleteAccount: return "/api/auth/me"

        // Feed
        case .feedToken: return "/api/feed/token"
        case .generateFeedToken: return "/api/feed/generate-token"
        case .revokeFeedToken: return "/api/feed/revoke-token"

        // Push Notifications
        case .registerDevice: return "/api/notifications/register-device"
        case .unregisterDevice: return "/api/notifications/unregister-device"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .register, .refreshToken, .logout,
             .forgotPassword, .resetPassword, .changePassword,
             .createHousehold, .joinHousehold, .regenerateCode,
             .createTask, .createSubtask, .createComment,
             .createCategory,
             .uploadAttachment, .uploadAvatar,
             .markCommentSeen, .markAllNotificationsRead,
             .registerDevice, .reorderTasks, .createReport,
             .generateFeedToken:
            return .POST
        case .me, .myHousehold, .task, .taskTemplates,
             .getTasks, .getSubtasks, .getComments,
             .getCategories,
             .notifications, .notificationPreferences,
             .dashboardStats, .overviewStats,
             .feedToken:
            return .GET
        case .updateMe, .updateTask, .subtask, .comment, .category,
             .markNotificationRead:
            return .PATCH
        case .deleteTask, .deleteSubtask, .deleteComment,
             .deleteAttachment, .deleteAccount, .unregisterDevice,
             .revokeFeedToken:
            return .DELETE
        }
    }
}

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}
