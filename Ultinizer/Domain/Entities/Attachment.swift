import Foundation

struct Attachment: Identifiable, Equatable, Hashable {
    let id: String
    let taskId: String
    let commentId: String?
    let filename: String
    let originalName: String
    let mimeType: String
    let size: Int
    let url: String
    let thumbnailUrl: String?
    let uploadedById: String
    let createdAt: Date

    var isImage: Bool {
        mimeType.hasPrefix("image/")
    }

    var fullURL: URL? {
        // url is relative, e.g. "/uploads/uuid.jpg"
        // Full URL built by prepending the base URL at the call site
        URL(string: url)
    }
}
