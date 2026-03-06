import Foundation

protocol AttachmentRepositoryProtocol: Sendable {
    func uploadAttachment(taskId: String, fileData: Data, fileName: String, mimeType: String) async throws -> Attachment
    func deleteAttachment(id: String) async throws
}
