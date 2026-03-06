import Foundation

protocol SubtaskRepositoryProtocol: Sendable {
    func createSubtask(taskId: String, title: String) async throws -> Subtask
    func updateSubtask(taskId: String, subtaskId: String, title: String?, isCompleted: Bool?, sortOrder: Int?) async throws -> Subtask
    func deleteSubtask(taskId: String, subtaskId: String) async throws
}
