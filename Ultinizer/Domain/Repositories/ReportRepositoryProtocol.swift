import Foundation

enum ReportTargetType: String {
    case comment
    case attachment
}

enum ReportReason: String, CaseIterable {
    case spam
    case harassment
    case inappropriate
    case other

    var displayName: String {
        switch self {
        case .spam: return "Spam"
        case .harassment: return "Harassment"
        case .inappropriate: return "Inappropriate Content"
        case .other: return "Other"
        }
    }
}

protocol ReportRepositoryProtocol: Sendable {
    func createReport(
        targetType: ReportTargetType,
        targetId: String,
        reason: ReportReason,
        description: String?
    ) async throws
}
