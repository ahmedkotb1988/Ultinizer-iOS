import Foundation

final class AttachmentRepository: AttachmentRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func uploadAttachment(taskId: String, fileData: Data, fileName: String, mimeType: String) async throws -> Attachment {
        let dto: AttachmentDTO = try await apiClient.upload(
            endpoint: .uploadAttachment(taskId: taskId),
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            fieldName: "file"
        )
        return AttachmentMapper.map(dto)
    }

    func deleteAttachment(id: String) async throws {
        try await apiClient.request(endpoint: .deleteAttachment(id: id))
    }
}
