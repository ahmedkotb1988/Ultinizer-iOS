import SwiftUI

struct NotificationsScreen: View {
    @State private var notifications: [AppNotification] = []
    @State private var isLoading = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private let container: AppContainer
    private let router: AppRouter

    init(container: AppContainer, router: AppRouter) {
        self.container = container
        self.router = router
    }

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    Spacer()
                    LoadingView()
                    Spacer()
                } else if notifications.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "bell.slash",
                        title: "No notifications",
                        description: "You're all caught up!"
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(notifications) { notification in
                                notificationRow(notification)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.gray400)
                    }
                    .accessibilityLabel("Close")
                }
                if !notifications.isEmpty {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: { Task { await markAllRead() } }) {
                            Text("Read All")
                                .font(AppTypography.labelMedium)
                                .foregroundColor(AppColors.magenta500)
                        }
                        .accessibilityLabel("Mark all notifications as read")
                    }
                }
            }
            .task {
                await loadNotifications()
            }
        }
    }

    @ViewBuilder
    private func notificationRow(_ notification: AppNotification) -> some View {
        Button(action: {
            Task { await markRead(notification) }
            if let taskId = notification.taskId {
                dismiss()
                router.navigate(to: .taskDetail(id: taskId))
            }
        }) {
            HStack(alignment: .top, spacing: AppSpacing.lg) {
                Circle()
                    .fill(notification.isRead ? .clear : AppColors.magenta500)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(notification.title)
                        .font(notification.isRead ? AppTypography.label : AppTypography.labelSemiBold)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(notification.body)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(notification.createdAt.formatted(.relative(presentation: .named)))
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.gray400)
                }

                Spacer()
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.lg)
            .background(
                notification.isRead
                ? AppColors.backgroundPrimary
                : (colorScheme == .dark ? AppColors.magenta950.opacity(0.3) : AppColors.magenta50.opacity(0.5))
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(notification.isRead ? "" : "Unread. ")\(notification.title). \(notification.body)")
        Divider().foregroundColor(AppColors.borderSecondary)
            .accessibilityHidden(true)
    }

    private func loadNotifications() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await container.notificationRepository.getNotifications(cursor: nil, limit: 50)
            notifications = result.notifications
        } catch {
            // Silent
        }
    }

    private func markRead(_ notification: AppNotification) async {
        guard !notification.isRead else { return }
        try? await container.notificationRepository.markAsRead(id: notification.id)
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            let old = notifications[index]
            notifications[index] = AppNotification(
                id: old.id, userId: old.userId, type: old.type, title: old.title,
                body: old.body, taskId: old.taskId, commentId: old.commentId,
                isRead: true, createdAt: old.createdAt
            )
        }
    }

    private func markAllRead() async {
        try? await container.notificationRepository.markAllAsRead()
        notifications = notifications.map {
            AppNotification(
                id: $0.id, userId: $0.userId, type: $0.type, title: $0.title,
                body: $0.body, taskId: $0.taskId, commentId: $0.commentId,
                isRead: true, createdAt: $0.createdAt
            )
        }
    }
}
