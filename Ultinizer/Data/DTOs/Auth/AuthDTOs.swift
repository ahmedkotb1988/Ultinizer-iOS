import Foundation

// MARK: - Request DTOs

struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}

struct RegisterRequestDTO: Encodable {
    let email: String
    let password: String
    let displayName: String
    let roleLabel: String?
}

struct ForgotPasswordRequestDTO: Encodable {
    let email: String
}

struct ResetPasswordRequestDTO: Encodable {
    let token: String
    let password: String
}

struct ChangePasswordRequestDTO: Encodable {
    let currentPassword: String
    let newPassword: String
}

struct UpdateMeRequestDTO: Encodable {
    let displayName: String?
    let roleLabel: String?
}

// MARK: - Response DTOs

struct LoginResponseDTO: Decodable {
    let user: UserDTO
    let tokens: TokenPairDTO
    let household: HouseholdDTO?
}

struct UserDTO: Codable {
    let id: String
    let email: String
    let displayName: String
    let avatarUrl: String?
    let roleLabel: String?
    let householdId: String?
    let createdAt: Date
    let updatedAt: Date
}

struct HouseholdDTO: Decodable {
    let id: String
    let name: String
    let inviteCode: String
    let createdAt: Date
    let updatedAt: Date
    let members: [UserDTO]?
}

struct AvatarResponseDTO: Decodable {
    let avatarUrl: String
}

// MARK: - Me endpoint response (can return user + household)

struct MeResponseDTO: Decodable {
    let id: String
    let email: String
    let displayName: String
    let avatarUrl: String?
    let roleLabel: String?
    let householdId: String?
    let createdAt: Date
    let updatedAt: Date
}
