import Foundation

enum APIError: Error, Equatable {
    case unauthorized
    case invalidCredentials
    case emailExists
    case invalidToken
    case invalidPassword
    case samePassword
    case notFound
    case noHousehold
    case alreadyInHousehold
    case invalidCode
    case forbidden
    case invalidCategory
    case duplicate
    case cannotEditDefault
    case cannotDeleteDefault
    case categoryInUse
    case noFile
    case invalidType
    case fileTooLarge
    case invalidParent
    case networkError(String)
    case decodingError(String)
    case serverError(Int, String)
    case sessionExpired
    case unknown(String)

    var userMessage: String {
        switch self {
        case .unauthorized, .sessionExpired:
            return "Session expired. Please sign in again."
        case .invalidCredentials:
            return "Invalid email or password."
        case .emailExists:
            return "An account with this email already exists."
        case .invalidToken:
            return "Invalid or expired token."
        case .invalidPassword:
            return "Current password is incorrect."
        case .samePassword:
            return "New password must be different from your current password."
        case .notFound:
            return "The requested resource was not found."
        case .noHousehold:
            return "You are not part of a household."
        case .alreadyInHousehold:
            return "You are already in a household."
        case .invalidCode:
            return "Invalid invite code."
        case .forbidden:
            return "You don't have permission to perform this action."
        case .invalidCategory:
            return "Invalid category selection."
        case .duplicate:
            return "This item already exists."
        case .cannotEditDefault:
            return "Default categories cannot be edited."
        case .cannotDeleteDefault:
            return "Default categories cannot be deleted."
        case .categoryInUse:
            return "This category is in use and cannot be deleted."
        case .noFile:
            return "No file was provided."
        case .invalidType:
            return "File type is not supported."
        case .fileTooLarge:
            return "File size exceeds the 10MB limit."
        case .invalidParent:
            return "Parent comment not found."
        case .networkError(let message):
            return message
        case .decodingError:
            return "Failed to process server response."
        case .serverError(_, let message):
            return message
        case .unknown(let message):
            return message
        }
    }

    static func from(code: String, message: String = "") -> APIError {
        switch code {
        case "UNAUTHORIZED": return .unauthorized
        case "INVALID_CREDENTIALS": return .invalidCredentials
        case "EMAIL_EXISTS": return .emailExists
        case "INVALID_TOKEN": return .invalidToken
        case "INVALID_PASSWORD": return .invalidPassword
        case "SAME_PASSWORD": return .samePassword
        case "NOT_FOUND": return .notFound
        case "NO_HOUSEHOLD": return .noHousehold
        case "ALREADY_IN_HOUSEHOLD": return .alreadyInHousehold
        case "INVALID_CODE": return .invalidCode
        case "FORBIDDEN": return .forbidden
        case "INVALID_CATEGORY": return .invalidCategory
        case "DUPLICATE": return .duplicate
        case "CANNOT_EDIT_DEFAULT": return .cannotEditDefault
        case "CANNOT_DELETE_DEFAULT": return .cannotDeleteDefault
        case "CATEGORY_IN_USE": return .categoryInUse
        case "NO_FILE": return .noFile
        case "INVALID_TYPE": return .invalidType
        case "FILE_TOO_LARGE": return .fileTooLarge
        case "INVALID_PARENT": return .invalidParent
        case "NETWORK_ERROR": return .networkError(message)
        default: return .unknown(message.isEmpty ? "An unexpected error occurred." : message)
        }
    }
}
