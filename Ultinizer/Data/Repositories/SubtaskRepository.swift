import Foundation

final class SubtaskRepository: SubtaskRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func createSubtask(taskId: String, title: String) async throws -> Subtask {
        let request = CreateSubtaskRequestDTO(title: title)
        let dto: SubtaskDTO = try await apiClient.request(
            endpoint: .createSubtask(taskId: taskId),
            body: request
        )
        return SubtaskMapper.map(dto)
    }

    func updateSubtask(taskId: String, subtaskId: String, title: String?, isCompleted: Bool?, sortOrder: Int?) async throws -> Subtask {
        let request = UpdateSubtaskRequestDTO(title: title, isCompleted: isCompleted, sortOrder: sortOrder)
        let dto: SubtaskDTO = try await apiClient.request(
            endpoint: .subtask(taskId: taskId, subtaskId: subtaskId),
            body: request
        )
        return SubtaskMapper.map(dto)
    }

    func deleteSubtask(taskId: String, subtaskId: String) async throws {
        try await apiClient.request(endpoint: .subtask(taskId: taskId, subtaskId: subtaskId))
    }
}
