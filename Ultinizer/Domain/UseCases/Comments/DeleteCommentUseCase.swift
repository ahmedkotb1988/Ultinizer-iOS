import Foundation

protocol DeleteCommentUseCaseProtocol: Sendable {
    func execute(taskId: String, commentId: String) async throws
}

final class DeleteCommentUseCase: DeleteCommentUseCaseProtocol, @unchecked Sendable {
    private let commentRepository: CommentRepositoryProtocol

    init(commentRepository: CommentRepositoryProtocol) {
        self.commentRepository = commentRepository
    }

    func execute(taskId: String, commentId: String) async throws {
        try await commentRepository.deleteComment(taskId: taskId, commentId: commentId)
    }
}
