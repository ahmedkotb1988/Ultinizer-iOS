import Foundation

protocol GetTaskUseCaseProtocol: Sendable {
    func execute(id: String) async throws -> HouseholdTask
}

final class GetTaskUseCase: GetTaskUseCaseProtocol, @unchecked Sendable {
    private let taskRepository: TaskRepositoryProtocol

    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }

    func execute(id: String) async throws -> HouseholdTask {
        try await taskRepository.getTask(id: id)
    }
}
