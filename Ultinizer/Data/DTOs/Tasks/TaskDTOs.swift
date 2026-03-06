import Foundation

// MARK: - Task Response DTO

struct TaskDTO: Decodable {
    let id: String
    let title: String
    let description: String?
    let categoryId: String
    let category: TaskCategoryDTO?
    let priority: String
    let status: String
    let assignmentType: String?
    let dueDate: Date?
    let estimatedMinutes: Int?
    let householdId: String
    let createdById: String
    let createdBy: UserDTO?
    let assignees: [TaskAssigneeDTO]?
    let subtasks: [SubtaskDTO]?
    let attachments: [AttachmentDTO]?
    let comments: [CommentDTO]?
    let recurrence: TaskRecurrenceDTO?
    let isTemplate: Bool?
    let templateId: String?
    let sortOrder: Int?
    let createdAt: Date
    let updatedAt: Date
    let completedAt: Date?
    let verifiedAt: Date?
    let verifiedById: String?
}

struct TaskAssigneeDTO: Decodable {
    let userId: String
    let taskId: String
    let user: UserDTO?
}

struct SubtaskDTO: Decodable {
    let id: String
    let taskId: String
    let title: String
    let isCompleted: Bool
    let sortOrder: Int
    let createdAt: Date
}

struct TaskCategoryDTO: Decodable {
    let id: String
    let name: String
    let householdId: String
    let isDefault: Bool?
    let color: String?
    let icon: String?
    let createdAt: Date
}

struct AttachmentDTO: Decodable {
    let id: String
    let taskId: String
    let commentId: String?
    let filename: String
    let originalName: String
    let mimeType: String
    let size: Int
    let url: String
    let thumbnailUrl: String?
    let uploadedById: String
    let createdAt: Date
}

struct CommentDTO: Decodable {
    let id: String
    let taskId: String
    let authorId: String
    let author: UserDTO?
    let content: String
    let parentId: String?
    let isEdited: Bool?
    let attachments: [AttachmentDTO]?
    let seenBy: [CommentSeenDTO]?
    let createdAt: Date
    let updatedAt: Date
}

struct CommentSeenDTO: Decodable {
    let userId: String
    let commentId: String
    let seenAt: Date
}

struct TaskRecurrenceDTO: Decodable {
    let type: String
    let interval: Int
    let daysOfWeek: [Int]?
    let dayOfMonth: Int?
    let cronExpression: String?
}

// MARK: - Request DTOs

struct CreateTaskRequestDTO: Encodable {
    let title: String
    let description: String?
    let categoryId: String
    let priority: String?
    let assignmentType: String?
    let assigneeIds: [String]
    let dueDate: Date?
    let estimatedMinutes: Int?
    let isTemplate: Bool?
    let templateId: String?
    let subtasks: [SubtaskInputDTO]?
    let recurrence: TaskRecurrenceInputDTO?
}

struct SubtaskInputDTO: Encodable {
    let title: String
}

struct TaskRecurrenceInputDTO: Encodable {
    let type: String
    let interval: Int
    let daysOfWeek: [Int]?
    let dayOfMonth: Int?
    let cronExpression: String?
}

struct UpdateTaskRequestDTO: Encodable {
    let title: String?
    let description: String?
    let categoryId: String?
    let priority: String?
    let assignmentType: String?
    let assigneeIds: [String]?
    let dueDate: Date?
    let estimatedMinutes: Int?
    let status: String?
    let sortOrder: Int?
    let isTemplate: Bool?
    let recurrence: TaskRecurrenceInputDTO?
}

struct ReorderTasksRequestDTO: Encodable {
    let tasks: [ReorderItemDTO]
}

struct ReorderItemDTO: Encodable {
    let id: String
    let sortOrder: Int
}

struct CreateSubtaskRequestDTO: Encodable {
    let title: String
}

struct UpdateSubtaskRequestDTO: Encodable {
    let title: String?
    let isCompleted: Bool?
    let sortOrder: Int?
}

struct CreateCommentRequestDTO: Encodable {
    let content: String
    let parentId: String?
}

struct UpdateCommentRequestDTO: Encodable {
    let content: String
}

// MARK: - Category Request DTOs

struct CreateCategoryRequestDTO: Encodable {
    let name: String
    let color: String?
    let icon: String?
}

struct UpdateCategoryRequestDTO: Encodable {
    let name: String?
    let color: String?
    let icon: String?
}

// MARK: - Notification DTOs

struct NotificationDTO: Decodable {
    let id: String
    let userId: String
    let type: String
    let title: String
    let body: String
    let taskId: String?
    let commentId: String?
    let isRead: Bool
    let createdAt: Date
}

struct NotificationPreferencesDTO: Codable {
    let userId: String?
    let quietHoursStart: String?
    let quietHoursEnd: String?
    let categoryMutes: [String]?
    let typeMutes: [String]?
    let dueSoonMinutes: Int?
}

// MARK: - Stats DTOs

struct DashboardStatsDTO: Decodable {
    let todayTasks: [TaskDTO]
    let overdueTasks: [TaskDTO]
    let upcomingTasks: [TaskDTO]
    let recentActivity: [ActivityItemDTO]?
}

struct ActivityItemDTO: Decodable {
    let type: String
    let description: String
    let createdAt: Date
}

struct StatsOverviewDTO: Decodable {
    let completionRate: Double
    let totalTasks: Int
    let completedTasks: Int
    let byCategory: [CategoryStatDTO]?
    let byMember: [MemberStatDTO]?
    let streak: StreakDTO?
    let weeklyTrend: [WeeklyTrendDTO]?
}

struct CategoryStatDTO: Decodable {
    let categoryId: String
    let categoryName: String
    let count: Int
}

struct MemberStatDTO: Decodable {
    let userId: String
    let displayName: String
    let total: Int
    let completed: Int
}

struct StreakDTO: Decodable {
    let current: Int
    let longest: Int
}

struct WeeklyTrendDTO: Decodable {
    let date: String
    let completed: Int
    let created: Int
}

// MARK: - Push Token

struct PushTokenRequestDTO: Encodable {
    let token: String
}

// MARK: - Household Request DTOs

struct CreateHouseholdRequestDTO: Encodable {
    let name: String
}

struct JoinHouseholdRequestDTO: Encodable {
    let inviteCode: String
}
