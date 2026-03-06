import Foundation

struct TaskFilters {
    var status: TaskStatus?
    var priority: TaskPriority?
    var categoryId: String?
    var assigneeId: String?
    var search: String?
    var dueBefore: Date?
    var dueAfter: Date?
    var sortBy: TaskSortBy?
    var sortOrder: SortOrder?
    var cursor: String?
    var limit: Int?
}

enum TaskSortBy: String {
    case dueDate
    case priority
    case createdAt
    case title
}

enum SortOrder: String {
    case asc
    case desc
}

struct TaskListResult {
    let tasks: [HouseholdTask]
    let cursor: String?
    let hasMore: Bool
}

struct CreateTaskInput: Equatable {
    let title: String
    let description: String?
    let categoryId: String
    let priority: TaskPriority
    let assignmentType: AssignmentType
    let assigneeIds: [String]
    let dueDate: Date?
    let estimatedMinutes: Int?
    let isTemplate: Bool
    let templateId: String?
    let subtasks: [SubtaskInput]
    let recurrence: TaskRecurrenceInput?
}

struct SubtaskInput: Equatable {
    let title: String
}

struct TaskRecurrenceInput: Equatable {
    let type: RecurrenceType
    let interval: Int
    let daysOfWeek: [Int]?
    let dayOfMonth: Int?
    let cronExpression: String?
}

struct UpdateTaskInput {
    var title: String?
    var description: String?
    var categoryId: String?
    var priority: TaskPriority?
    var assignmentType: AssignmentType?
    var assigneeIds: [String]?
    var dueDate: Date?
    var estimatedMinutes: Int?
    var status: TaskStatus?
    var sortOrder: Int?
    var isTemplate: Bool?
    var recurrence: TaskRecurrenceInput?
}

protocol TaskRepositoryProtocol: Sendable {
    func getTasks(filters: TaskFilters) async throws -> TaskListResult
    func getTask(id: String) async throws -> HouseholdTask
    func createTask(input: CreateTaskInput) async throws -> HouseholdTask
    func updateTask(id: String, input: UpdateTaskInput) async throws -> HouseholdTask
    func deleteTask(id: String) async throws
    func reorderTasks(tasks: [(id: String, sortOrder: Int)]) async throws
    func getTemplates() async throws -> [HouseholdTask]
}
