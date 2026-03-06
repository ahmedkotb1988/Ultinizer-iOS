import Foundation

protocol CreateTaskUseCaseProtocol: Sendable {
    func execute(input: CreateTaskInput) async throws -> HouseholdTask
}

final class CreateTaskUseCase: CreateTaskUseCaseProtocol, @unchecked Sendable {
    private let taskRepository: TaskRepositoryProtocol

    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }

    func execute(input: CreateTaskInput) async throws -> HouseholdTask {
        guard !input.title.isEmpty else {
            throw APIError.unknown("Title is required")
        }
        guard !input.categoryId.isEmpty else {
            throw APIError.unknown("Category is required")
        }
        guard !input.assigneeIds.isEmpty else {
            throw APIError.unknown("At least one assignee is required")
        }
        return try await taskRepository.createTask(input: input)
    }
}
