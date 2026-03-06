import Foundation

struct Comment: Identifiable, Equatable, Hashable {
    let id: String
    let taskId: String
    let authorId: String
    let author: User?
    let content: String
    let parentId: String?
    let isEdited: Bool
    let attachments: [Attachment]
    let seenBy: [CommentSeen]
    let createdAt: Date
    let updatedAt: Date
}

struct CommentSeen: Equatable, Hashable {
    let userId: String
    let commentId: String
    let seenAt: Date
}
