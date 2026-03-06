import Foundation

protocol DeleteTaskUseCaseProtocol: Sendable {
    func execute(id: String) async throws
}

final class DeleteTaskUseCase: DeleteTaskUseCaseProtocol, @unchecked Sendable {
    private let taskRepository: TaskRepositoryProtocol

    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }

    func execute(id: String) async throws {
        try await taskRepository.deleteTask(id: id)
    }
}
