import Foundation

protocol CreateCommentUseCaseProtocol: Sendable {
    func execute(taskId: String, content: String, parentId: String?) async throws -> Comment
}

final class CreateCommentUseCase: CreateCommentUseCaseProtocol, @unchecked Sendable {
    private let commentRepository: CommentRepositoryProtocol

    init(commentRepository: CommentRepositoryProtocol) {
        self.commentRepository = commentRepository
    }

    func execute(taskId: String, content: String, parentId: String? = nil) async throws -> Comment {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw APIError.unknown("Comment content is required")
        }
        return try await commentRepository.createComment(taskId: taskId, content: content, parentId: parentId)
    }
}
