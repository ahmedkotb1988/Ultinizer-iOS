import Foundation

struct Subtask: Identifiable, Equatable, Hashable {
    let id: String
    let taskId: String
    let title: String
    let isCompleted: Bool
    let sortOrder: Int
    let createdAt: Date
}
