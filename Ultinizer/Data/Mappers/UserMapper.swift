import Foundation

struct UserMapper {
    static func map(_ dto: UserDTO) -> User {
        User(
            id: dto.id,
            email: dto.email,
            displayName: dto.displayName,
            avatarUrl: dto.avatarUrl,
            roleLabel: dto.roleLabel ?? "",
            householdId: dto.householdId,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt
        )
    }

    static func map(_ dto: MeResponseDTO) -> User {
        User(
            id: dto.id,
            email: dto.email,
            displayName: dto.displayName,
            avatarUrl: dto.avatarUrl,
            roleLabel: dto.roleLabel ?? "",
            householdId: dto.householdId,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt
        )
    }
}

struct HouseholdMapper {
    static func map(_ dto: HouseholdDTO) -> Household {
        Household(
            id: dto.id,
            name: dto.name,
            inviteCode: dto.inviteCode,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            members: (dto.members ?? []).map(UserMapper.map)
        )
    }
}
