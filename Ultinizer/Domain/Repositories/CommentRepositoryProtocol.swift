import Foundation

protocol CommentRepositoryProtocol: Sendable {
    func getComments(taskId: String) async throws -> [Comment]
    func createComment(taskId: String, content: String, parentId: String?) async throws -> Comment
    func updateComment(taskId: String, commentId: String, content: String) async throws -> Comment
    func deleteComment(taskId: String, commentId: String) async throws
    func markCommentSeen(taskId: String, commentId: String) async throws
}
