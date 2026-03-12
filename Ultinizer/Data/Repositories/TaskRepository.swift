import Foundation

final class TaskRepository: TaskRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func getTasks(filters: TaskFilters) async throws -> TaskListResult {
        var queryItems: [URLQueryItem] = []

        if let status = filters.status { queryItems.append(.init(name: "status", value: status.rawValue)) }
        if let priority = filters.priority { queryItems.append(.init(name: "priority", value: priority.rawValue)) }
        if let categoryId = filters.categoryId { queryItems.append(.init(name: "categoryId", value: categoryId)) }
        if let assigneeId = filters.assigneeId { queryItems.append(.init(name: "assigneeId", value: assigneeId)) }
        if let search = filters.search, !search.isEmpty { queryItems.append(.init(name: "search", value: search)) }
        if let dueBefore = filters.dueBefore { queryItems.append(.init(name: "dueBefore", value: ISO8601DateFormatter.full.string(from: dueBefore))) }
        if let dueAfter = filters.dueAfter { queryItems.append(.init(name: "dueAfter", value: ISO8601DateFormatter.full.string(from: dueAfter))) }
        if let sortBy = filters.sortBy { queryItems.append(.init(name: "sortBy", value: sortBy.rawValue)) }
        if let sortOrder = filters.sortOrder { queryItems.append(.init(name: "sortOrder", value: sortOrder.rawValue)) }
        if let cursor = filters.cursor { queryItems.append(.init(name: "cursor", value: cursor)) }
        if let limit = filters.limit { queryItems.append(.init(name: "limit", value: String(limit))) }

        // The API returns { success, data: Task[], meta }
        // Our APIClient decodes the `data` field, so we need a wrapper
        let tasks: [TaskDTO] = try await apiClient.request(
            endpoint: .getTasks,
            queryItems: queryItems.isEmpty ? nil : queryItems
        )

        return TaskListResult(
            tasks: tasks.map(TaskMapper.map),
            cursor: nil,
            hasMore: false
        )
    }

    func getTask(id: String) async throws -> HouseholdTask {
        let dto: TaskDTO = try await apiClient.request(endpoint: .task(id: id))
        return TaskMapper.map(dto)
    }

    func createTask(input: CreateTaskInput) async throws -> HouseholdTask {
        let request = CreateTaskRequestDTO(
            title: input.title,
            description: input.description,
            categoryId: input.categoryId,
            priority: input.priority.rawValue,
            assignmentType: input.assignmentType.rawValue,
            assigneeIds: input.assigneeIds,
            dueDate: input.dueDate,
            estimatedMinutes: input.estimatedMinutes,
            isTemplate: input.isTemplate ? true : nil,
            templateId: input.templateId,
            subtasks: input.subtasks.isEmpty ? nil : input.subtasks.map { SubtaskInputDTO(title: $0.title) },
            recurrence: input.recurrence.map {
                TaskRecurrenceInputDTO(
                    type: $0.type.rawValue,
                    interval: $0.interval,
                    daysOfWeek: $0.daysOfWeek,
                    dayOfMonth: $0.dayOfMonth,
                    cronExpression: $0.cronExpression
                )
            }
        )
        let dto: TaskDTO = try await apiClient.request(endpoint: .createTask, body: request)
        return TaskMapper.map(dto)
    }

    func updateTask(id: String, input: UpdateTaskInput) async throws -> HouseholdTask {
        let request = UpdateTaskRequestDTO(
            title: input.title,
            description: input.description,
            categoryId: input.categoryId,
            priority: input.priority?.rawValue,
            assignmentType: input.assignmentType?.rawValue,
            assigneeIds: input.assigneeIds,
            dueDate: input.dueDate,
            estimatedMinutes: input.estimatedMinutes,
            status: input.status?.rawValue,
            sortOrder: input.sortOrder,
            isTemplate: input.isTemplate,
            recurrence: input.recurrence.map {
                TaskRecurrenceInputDTO(
                    type: $0.type.rawValue,
                    interval: $0.interval,
                    daysOfWeek: $0.daysOfWeek,
                    dayOfMonth: $0.dayOfMonth,
                    cronExpression: $0.cronExpression
                )
            }
        )
        let dto: TaskDTO = try await apiClient.request(endpoint: .updateTask(id: id), body: request)
        return TaskMapper.map(dto)
    }

    func deleteTask(id: String) async throws {
        try await apiClient.request(endpoint: .deleteTask(id: id))
    }

    func reorderTasks(tasks: [(id: String, sortOrder: Int)]) async throws {
        let request = ReorderTasksRequestDTO(
            tasks: tasks.map { ReorderItemDTO(id: $0.id, sortOrder: $0.sortOrder) }
        )
        try await apiClient.request(endpoint: .reorderTasks, body: request)
    }

    func getTemplates() async throws -> [HouseholdTask] {
        let dtos: [TaskDTO] = try await apiClient.request(endpoint: .taskTemplates)
        return dtos.map(TaskMapper.map)
    }
}
