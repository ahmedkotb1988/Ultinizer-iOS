import Foundation
import Observation
import UIKit

@Observable
final class TaskDetailViewModel {
    var task: HouseholdTask?
    var comments: [Comment] = []
    var isLoading = false
    var errorMessage = ""
    var replyTo: Comment?
    var togglingSubtasks: Set<String> = []

    private let getTaskUseCase: GetTaskUseCaseProtocol
    private let updateTaskUseCase: UpdateTaskUseCaseProtocol
    private let deleteTaskUseCase: DeleteTaskUseCaseProtocol
    private let getCommentsUseCase: GetCommentsUseCaseProtocol
    private let createCommentUseCase: CreateCommentUseCaseProtocol
    private let deleteCommentUseCase: DeleteCommentUseCaseProtocol
    private let subtaskRepository: SubtaskRepositoryProtocol

    init(
        getTaskUseCase: GetTaskUseCaseProtocol,
        updateTaskUseCase: UpdateTaskUseCaseProtocol,
        deleteTaskUseCase: DeleteTaskUseCaseProtocol,
        getCommentsUseCase: GetCommentsUseCaseProtocol,
        createCommentUseCase: CreateCommentUseCaseProtocol,
        deleteCommentUseCase: DeleteCommentUseCaseProtocol,
        subtaskRepository: SubtaskRepositoryProtocol
    ) {
        self.getTaskUseCase = getTaskUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
        self.getCommentsUseCase = getCommentsUseCase
        self.createCommentUseCase = createCommentUseCase
        self.deleteCommentUseCase = deleteCommentUseCase
        self.subtaskRepository = subtaskRepository
    }

    var rootComments: [Comment] {
        comments.filter { $0.parentId == nil }
    }

    func childComments(for parentId: String) -> [Comment] {
        comments.filter { $0.parentId == parentId }
    }

    var isOverdue: Bool {
        task?.isOverdue ?? false
    }

    @MainActor
    func loadTask(id: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            task = try await getTaskUseCase.execute(id: id)
            comments = try await getCommentsUseCase.execute(taskId: id)
        } catch {
            errorMessage = "Failed to load task"
        }
    }

    @MainActor
    func changeStatus(_ status: TaskStatus) async {
        guard let task else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        do {
            let input = UpdateTaskInput(status: status)
            self.task = try await updateTaskUseCase.execute(id: task.id, input: input)
        } catch {
            errorMessage = "Failed to update status"
        }
    }

    @MainActor
    func deleteTask() async -> Bool {
        guard let task else { return false }
        do {
            try await deleteTaskUseCase.execute(id: task.id)
            return true
        } catch {
            errorMessage = "Failed to delete task"
            return false
        }
    }

    @MainActor
    func toggleSubtask(_ subtask: Subtask) async {
        guard let task, !togglingSubtasks.contains(subtask.id) else { return }
        togglingSubtasks.insert(subtask.id)
        defer { togglingSubtasks.remove(subtask.id) }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        do {
            _ = try await subtaskRepository.updateSubtask(
                taskId: task.id,
                subtaskId: subtask.id,
                title: nil,
                isCompleted: !subtask.isCompleted,
                sortOrder: nil
            )
            // Reload task to get fresh subtask state
            self.task = try await getTaskUseCase.execute(id: task.id)
        } catch {
            // Revert on error
        }
    }

    @MainActor
    func submitComment(content: String) async {
        guard let task else { return }
        do {
            let comment = try await createCommentUseCase.execute(
                taskId: task.id,
                content: content,
                parentId: replyTo?.id
            )
            comments.append(comment)
            replyTo = nil
        } catch {
            errorMessage = "Failed to post comment"
        }
    }

    @MainActor
    func deleteComment(commentId: String) async {
        guard let task else { return }
        do {
            try await deleteCommentUseCase.execute(taskId: task.id, commentId: commentId)
            comments.removeAll { $0.id == commentId }
        } catch {
            errorMessage = "Failed to delete comment"
        }
    }
}
