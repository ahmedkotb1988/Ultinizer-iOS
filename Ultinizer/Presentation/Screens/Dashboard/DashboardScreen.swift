import SwiftUI

struct DashboardScreen: View {
    @State private var viewModel: DashboardViewModel
    private let authManager: AuthManager
    private let router: AppRouter
    private let container: AppContainer

    @Environment(\.colorScheme) private var colorScheme

    init(container: AppContainer, authManager: AuthManager, router: AppRouter) {
        self.container = container
        self.authManager = authManager
        self.router = router
        _viewModel = State(initialValue: DashboardViewModel(getTasksUseCase: container.getTasksUseCase))
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text("\(viewModel.greeting),")
                                .font(AppTypography.label)
                                .foregroundColor(AppColors.gray500)
                            Text(authManager.user?.displayName ?? "")
                                .font(AppTypography.largeTitle)
                                .foregroundColor(AppColors.textPrimary)
                            if let household = authManager.household {
                                Text(household.name)
                                    .font(AppTypography.label)
                                    .foregroundColor(AppColors.magenta500)
                            }
                        }
                        Spacer()
                        Button(action: {
                            router.selectedTab = .profile
                        }) {
                            AvatarView(
                                name: authManager.user?.displayName ?? "",
                                imageURL: avatarURL,
                                size: .lg
                            )
                        }
                        .accessibilityLabel("Go to profile")
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.md)

                    // Overdue section
                    if !viewModel.overdueTasks.isEmpty {
                        sectionHeader(
                            icon: "exclamationmark.circle.fill",
                            title: "Overdue (\(viewModel.overdueTasks.count))",
                            iconColor: AppColors.red500,
                            titleColor: AppColors.red500
                        )
                        .accessibilityLabel("Overdue tasks: \(viewModel.overdueTasks.count)")
                        ForEach(viewModel.overdueTasks.prefix(3)) { task in
                            TaskCard(task: task, onTap: {
                                router.navigate(to: .taskDetail(id: task.id))
                            })
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    }

                    // Today section
                    HStack {
                        sectionHeader(
                            icon: "calendar.circle.fill",
                            title: "Today",
                            iconColor: AppColors.magenta500,
                            titleColor: AppColors.textPrimary
                        )
                        Spacer()
                        Button(action: {
                            router.selectedTab = .tasks
                        }) {
                            Text("See all")
                                .font(AppTypography.labelMedium)
                                .foregroundColor(AppColors.magenta500)
                        }
                        .accessibilityLabel("See all tasks")
                        .padding(.trailing, AppSpacing.screenHorizontal)
                    }

                    if viewModel.isLoading {
                        VStack {
                            TaskSkeletonView()
                            TaskSkeletonView()
                            TaskSkeletonView()
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                    } else if viewModel.todayTasks.isEmpty {
                        CardView {
                            VStack(spacing: AppSpacing.md) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(AppColors.green500)
                                Text("All caught up for today!")
                                    .font(AppTypography.label)
                                    .foregroundColor(AppColors.gray500)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.xl)
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                    } else {
                        ForEach(viewModel.todayTasks) { task in
                            TaskCard(task: task, onTap: {
                                router.navigate(to: .taskDetail(id: task.id))
                            })
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    }

                    // Upcoming section
                    if !viewModel.upcomingTasks.isEmpty {
                        sectionHeader(
                            icon: "clock.fill",
                            title: "Upcoming This Week",
                            iconColor: AppColors.blue500,
                            titleColor: AppColors.textPrimary
                        )
                        ForEach(viewModel.upcomingTasks.prefix(5)) { task in
                            TaskCard(task: task, onTap: {
                                router.navigate(to: .taskDetail(id: task.id))
                            })
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    }
                }
                .padding(.bottom, 120)
            }
            .refreshable {
                await viewModel.refresh()
            }

            // FAB
            FABView {
                router.showCreateTask = true
            }
            .accessibilityLabel("Create new task")
        }
        .background(AppColors.backgroundSecondary)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadDashboard()
        }
    }

    private var avatarURL: URL? {
        guard let urlString = authManager.user?.avatarUrl, !urlString.isEmpty else { return nil }
        return URL(string: container.baseURL.absoluteString + urlString)
    }

    private func sectionHeader(icon: String, title: String, iconColor: Color, titleColor: Color) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
            Text(title)
                .font(AppTypography.bodySemiBold)
                .foregroundColor(titleColor)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.vertical, AppSpacing.md)
    }
}
