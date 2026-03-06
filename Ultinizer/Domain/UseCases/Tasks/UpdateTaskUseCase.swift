import Foundation

protocol UpdateTaskUseCaseProtocol: Sendable {
    func execute(id: String, input: UpdateTaskInput) async throws -> HouseholdTask
}

final class UpdateTaskUseCase: UpdateTaskUseCaseProtocol, @unchecked Sendable {
    private let taskRepository: TaskRepositoryProtocol

    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }

    func execute(id: String, input: UpdateTaskInput) async throws -> HouseholdTask {
        try await taskRepository.updateTask(id: id, input: input)
    }
}
