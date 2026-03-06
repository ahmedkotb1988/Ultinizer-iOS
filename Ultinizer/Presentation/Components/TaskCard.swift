import SwiftUI

struct TaskCard: View {
    let task: HouseholdTask
    var onTap: (() -> Void)?
    var onStatusChange: ((TaskStatus) -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: AppSpacing.lg) {
                // Status icon
                statusIcon
                    .onTapGesture {
                        if let onStatusChange {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            let nextStatus = nextStatus(for: task.status)
                            onStatusChange(nextStatus)
                        }
                    }

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    // Title
                    Text(task.title)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                        .strikethrough(task.status == .done || task.status == .verified)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Meta row
                    HStack(spacing: AppSpacing.md) {
                        // Due date
                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 11))
                                Text(formatDueDate(dueDate))
                                    .font(AppTypography.caption)
                            }
                            .foregroundColor(task.isOverdue ? AppColors.red500 : AppColors.gray500)
                        }

                        // Subtask count
                        if !task.subtasks.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10))
                                Text("\(task.completedSubtasksCount)/\(task.subtasks.count)")
                                    .font(AppTypography.caption)
                            }
                            .foregroundColor(AppColors.textTertiary)
                        }

                        // Comment count
                        if !task.comments.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "bubble.right")
                                    .font(.system(size: 10))
                                Text("\(task.comments.count)")
                                    .font(AppTypography.caption)
                            }
                            .foregroundColor(AppColors.textTertiary)
                        }
                    }

                    // Badges
                    HStack(spacing: AppSpacing.xs) {
                        BadgeView(label: task.priority.displayName, color: priorityBadgeColor, size: .sm)
                        if let category = task.category {
                            BadgeView(label: category.name, color: .gray, size: .sm)
                        }
                    }
                }

                Spacer()

                // Assignee avatars
                if !task.assignees.isEmpty {
                    HStack(spacing: -8) {
                        ForEach(task.assignees.prefix(3), id: \.userId) { assignee in
                            AvatarView(
                                name: assignee.user?.displayName ?? "?",
                                size: .sm
                            )
                            .overlay(
                                Circle().stroke(colorScheme == .dark ? AppColors.gray800 : .white, lineWidth: 2)
                            )
                        }
                    }
                }
            }
            .padding(AppSpacing.cardPadding)
            .background(colorScheme == .dark ? AppColors.gray800 : .white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .stroke(colorScheme == .dark ? AppColors.gray700 : AppColors.gray100, lineWidth: 1)
            )
        }
        .buttonStyle(CardButtonStyle())
        .padding(.bottom, AppSpacing.md)
    }

    private var statusIcon: some View {
        Image(systemName: task.status.iconName)
            .font(.system(size: 22))
            .foregroundColor(statusColor)
            .accessibilityLabel("Status: \(task.status.displayName). Double tap to advance status")
    }

    private var statusColor: Color {
        switch task.status {
        case .todo: return AppColors.gray400
        case .inProgress: return AppColors.blue500
        case .done: return AppColors.green500
        case .verified: return AppColors.magenta500
        }
    }

    private var priorityBadgeColor: BadgeColor {
        switch task.priority {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .urgent: return .red
        }
    }

    private func nextStatus(for current: TaskStatus) -> TaskStatus {
        switch current {
        case .todo: return .inProgress
        case .inProgress: return .done
        case .done: return .verified
        case .verified: return .verified
        }
    }

    private func formatDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            return date.formatted(.dateTime.month(.abbreviated).day())
        }
    }
}
