import Foundation

protocol GetTasksUseCaseProtocol: Sendable {
    func execute(filters: TaskFilters) async throws -> TaskListResult
}

final class GetTasksUseCase: GetTasksUseCaseProtocol, @unchecked Sendable {
    private let taskRepository: TaskRepositoryProtocol

    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }

    func execute(filters: TaskFilters = TaskFilters()) async throws -> TaskListResult {
        try await taskRepository.getTasks(filters: filters)
    }
}
