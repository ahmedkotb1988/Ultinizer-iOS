import Foundation

struct Household: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let inviteCode: String
    let createdAt: Date
    let updatedAt: Date
    let members: [User]
}
