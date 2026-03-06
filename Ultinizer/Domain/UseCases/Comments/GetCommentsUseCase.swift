import Foundation

protocol GetCommentsUseCaseProtocol: Sendable {
    func execute(taskId: String) async throws -> [Comment]
}

final class GetCommentsUseCase: GetCommentsUseCaseProtocol, @unchecked Sendable {
    private let commentRepository: CommentRepositoryProtocol

    init(commentRepository: CommentRepositoryProtocol) {
        self.commentRepository = commentRepository
    }

    func execute(taskId: String) async throws -> [Comment] {
        try await commentRepository.getComments(taskId: taskId)
    }
}
