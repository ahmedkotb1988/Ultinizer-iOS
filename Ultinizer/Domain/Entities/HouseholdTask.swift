import Foundation

struct HouseholdTask: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let description: String?
    let categoryId: String
    let category: TaskCategory?
    let priority: TaskPriority
    let status: TaskStatus
    let assignmentType: AssignmentType
    let dueDate: Date?
    let estimatedMinutes: Int?
    let householdId: String
    let createdById: String
    let createdBy: User?
    let assignees: [TaskAssignee]
    let subtasks: [Subtask]
    let attachments: [Attachment]
    let comments: [Comment]
    let recurrence: TaskRecurrence?
    let isTemplate: Bool
    let templateId: String?
    let sortOrder: Int
    let createdAt: Date
    let updatedAt: Date
    let completedAt: Date?
    let verifiedAt: Date?
    let verifiedById: String?

    var isOverdue: Bool {
        guard let dueDate, status != .done, status != .verified else { return false }
        return dueDate < Date()
    }

    var completedSubtasksCount: Int {
        subtasks.filter(\.isCompleted).count
    }

    var dueDateString: String? {
        guard let dueDate else { return nil }
        return dueDate.formatted(date: .abbreviated, time: .shortened)
    }
}

enum TaskPriority: String, Codable, CaseIterable, Hashable {
    case low
    case medium
    case high
    case urgent

    var displayName: String {
        rawValue.capitalized
    }
}

enum TaskStatus: String, Codable, CaseIterable, Hashable {
    case todo
    case inProgress = "in_progress"
    case done
    case verified

    var displayName: String {
        switch self {
        case .todo: return "To Do"
        case .inProgress: return "In Progress"
        case .done: return "Done"
        case .verified: return "Verified"
        }
    }

    var iconName: String {
        switch self {
        case .todo: return "circle"
        case .inProgress: return "clock"
        case .done: return "checkmark.circle.fill"
        case .verified: return "checkmark.shield.fill"
        }
    }
}

enum AssignmentType: String, Codable, Hashable {
    case individual
    case shared
}

struct TaskAssignee: Equatable, Hashable {
    let userId: String
    let taskId: String
    let user: User?
}

struct TaskRecurrence: Equatable, Hashable {
    let type: RecurrenceType
    let interval: Int
    let daysOfWeek: [Int]?
    let dayOfMonth: Int?
    let cronExpression: String?
}

enum RecurrenceType: String, Codable, Hashable {
    case daily
    case weekly
    case biweekly
    case monthly
    case custom
}
