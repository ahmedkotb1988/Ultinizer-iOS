import Foundation

final class CommentRepository: CommentRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func getComments(taskId: String) async throws -> [Comment] {
        let dtos: [CommentDTO] = try await apiClient.request(endpoint: .getComments(taskId: taskId))
        return dtos.map(CommentMapper.map)
    }

    func createComment(taskId: String, content: String, parentId: String?) async throws -> Comment {
        let request = CreateCommentRequestDTO(content: content, parentId: parentId)
        let dto: CommentDTO = try await apiClient.request(endpoint: .createComment(taskId: taskId), body: request)
        return CommentMapper.map(dto)
    }

    func updateComment(taskId: String, commentId: String, content: String) async throws -> Comment {
        let request = UpdateCommentRequestDTO(content: content)
        let dto: CommentDTO = try await apiClient.request(
            endpoint: .comment(taskId: taskId, commentId: commentId),
            body: request
        )
        return CommentMapper.map(dto)
    }

    func deleteComment(taskId: String, commentId: String) async throws {
        try await apiClient.request(endpoint: .comment(taskId: taskId, commentId: commentId))
    }

    func markCommentSeen(taskId: String, commentId: String) async throws {
        try await apiClient.request(endpoint: .markCommentSeen(taskId: taskId, commentId: commentId))
    }
}
