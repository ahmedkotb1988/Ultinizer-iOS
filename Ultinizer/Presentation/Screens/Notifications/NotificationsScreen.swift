import SwiftUI

struct NotificationsScreen: View {
    @State private var notifications: [AppNotification] = []
    @State private var isLoading = false

    private let container: AppContainer
    private let router: AppRouter

    @Environment(\.colorScheme) private var colorScheme

    init(container: AppContainer, router: AppRouter) {
        self.container = container
        self.router = router
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { router.pop() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.magenta500)
                }
                .accessibilityLabel("Go back")
                Spacer()
                Text("Notifications")
                    .font(AppTypography.heading)
                    .foregroundColor(AppColors.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                if !notifications.isEmpty {
                    Button(action: { Task { await markAllRead() } }) {
                        Text("Read All")
                            .font(AppTypography.labelMedium)
                            .foregroundColor(AppColors.magenta500)
                    }
                    .accessibilityLabel("Mark all notifications as read")
                } else {
                    Color.clear.frame(width: 60)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.lg)
            .overlay(Divider().foregroundColor(AppColors.borderPrimary), alignment: .bottom)

            if isLoading {
                LoadingView()
            } else if notifications.isEmpty {
                EmptyStateView(
                    icon: "bell.slash",
                    title: "No notifications",
                    description: "You're all caught up!"
                )
                .frame(maxHeight: .infinity)
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
        .background(AppColors.backgroundSecondary)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadNotifications()
        }
    }

    @ViewBuilder
    private func notificationRow(_ notification: AppNotification) -> some View {
        Button(action: {
            Task { await markRead(notification) }
            if let taskId = notification.taskId {
                router.navigate(to: .taskDetail(id: taskId))
            }
        }) {
            HStack(alignment: .top, spacing: AppSpacing.lg) {
                // Unread indicator
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
