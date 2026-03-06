import Foundation

struct User: Identifiable, Equatable, Hashable {
    let id: String
    let email: String
    let displayName: String
    let avatarUrl: String?
    let roleLabel: String
    let householdId: String?
    let createdAt: Date
    let updatedAt: Date

    var initials: String {
        let parts = displayName.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(displayName.prefix(2)).uppercased()
    }
}
