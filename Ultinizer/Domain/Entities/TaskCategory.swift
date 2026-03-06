import Foundation

struct TaskCategory: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let householdId: String
    let isDefault: Bool
    let color: String?
    let icon: String?
    let createdAt: Date
}
