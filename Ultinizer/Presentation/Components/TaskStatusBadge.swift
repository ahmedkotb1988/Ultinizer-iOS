import SwiftUI

struct TaskStatusBadge: View {
    let status: TaskStatus

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
                .font(.system(size: 12))
            Text(status.displayName)
                .font(AppTypography.captionMedium)
        }
        .foregroundColor(statusColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(statusBackgroundColor)
        .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch status {
        case .todo: return AppColors.gray600
        case .inProgress: return AppColors.blue500
        case .done: return AppColors.green500
        case .verified: return AppColors.magenta500
        }
    }

    private var statusBackgroundColor: Color {
        switch status {
        case .todo: return colorScheme == .dark ? AppColors.gray700 : AppColors.gray100
        case .inProgress: return colorScheme == .dark ? Color(hex: "1E3A5F") : Color(hex: "DBEAFE")
        case .done: return colorScheme == .dark ? AppColors.green900 : AppColors.green50
        case .verified: return colorScheme == .dark ? AppColors.magenta900 : AppColors.magenta50
        }
    }
}

struct PriorityBadge: View {
    let priority: TaskPriority

    var body: some View {
        BadgeView(label: priority.displayName, color: badgeColor)
    }

    private var badgeColor: BadgeColor {
        switch priority {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .urgent: return .red
        }
    }
}
