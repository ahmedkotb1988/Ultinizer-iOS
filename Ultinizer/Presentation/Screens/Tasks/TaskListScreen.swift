import SwiftUI

struct TaskListScreen: View {
    @State private var viewModel: TaskListViewModel
    private let router: AppRouter
    private let authManager: AuthManager

    init(container: AppContainer, router: AppRouter, authManager: AuthManager) {
        self.router = router
        self.authManager = authManager
        _viewModel = State(initialValue: TaskListViewModel(
            getTasksUseCase: container.getTasksUseCase,
            updateTaskUseCase: container.updateTaskUseCase,
            categoryRepository: container.categoryRepository
        ))
    }

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Search and filters
                VStack(spacing: AppSpacing.md) {
                    // Search bar
                    HStack(spacing: AppSpacing.md) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.gray400)
                        TextField("Search tasks...", text: $viewModel.searchText)
                            .font(AppTypography.body)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onChange(of: viewModel.searchText) { _, _ in
                                Task { await viewModel.loadTasks() }
                            }
                        if !viewModel.searchText.isEmpty {
                            Button(action: {
                                viewModel.searchText = ""
                                Task { await viewModel.loadTasks() }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppColors.gray400)
                            }
                            .accessibilityLabel("Clear search")
                        }
                    }
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.vertical, AppSpacing.lg)
                    .background(colorScheme == .dark ? AppColors.gray800 : .white)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.md) {
                            filterChip(
                                label: viewModel.selectedStatus?.displayName ?? "Status",
                                isActive: viewModel.selectedStatus != nil
                            ) {
                                // Toggle through statuses
                                if let current = viewModel.selectedStatus,
                                   let nextIndex = TaskStatus.allCases.firstIndex(of: current).map({ $0 + 1 }),
                                   nextIndex < TaskStatus.allCases.count {
                                    viewModel.selectedStatus = TaskStatus.allCases[nextIndex]
                                } else {
                                    viewModel.selectedStatus = viewModel.selectedStatus == nil ? .todo : nil
                                }
                                Task { await viewModel.loadTasks() }
                            }

                            filterChip(
                                label: viewModel.selectedPriority?.displayName ?? "Priority",
                                isActive: viewModel.selectedPriority != nil
                            ) {
                                if let current = viewModel.selectedPriority,
                                   let nextIndex = TaskPriority.allCases.firstIndex(of: current).map({ $0 + 1 }),
                                   nextIndex < TaskPriority.allCases.count {
                                    viewModel.selectedPriority = TaskPriority.allCases[nextIndex]
                                } else {
                                    viewModel.selectedPriority = viewModel.selectedPriority == nil ? .low : nil
                                }
                                Task { await viewModel.loadTasks() }
                            }

                            ForEach(viewModel.categories) { category in
                                filterChip(
                                    label: category.name,
                                    isActive: viewModel.selectedCategoryId == category.id
                                ) {
                                    viewModel.selectedCategoryId = viewModel.selectedCategoryId == category.id ? nil : category.id
                                    Task { await viewModel.loadTasks() }
                                }
                            }

                            if viewModel.hasActiveFilters {
                                Button(action: {
                                    viewModel.clearFilters()
                                    Task { await viewModel.loadTasks() }
                                }) {
                                    Text("Clear")
                                        .font(AppTypography.captionMedium)
                                        .foregroundColor(AppColors.red500)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.xl)
                .padding(.bottom, AppSpacing.md)

                // Task list
                if viewModel.isLoading {
                    ScrollView {
                        VStack {
                            ForEach(0..<5, id: \.self) { _ in
                                TaskSkeletonView()
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                    }
                } else if viewModel.tasks.isEmpty {
                    EmptyStateView(
                        icon: "checklist",
                        title: "No tasks found",
                        description: "Create a task to get started",
                        actionTitle: "Create Task"
                    ) {
                        router.showCreateTask = true
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.tasks) { task in
                                TaskCard(
                                    task: task,
                                    onTap: {
                                        router.navigate(to: .taskDetail(id: task.id))
                                    },
                                    onStatusChange: { newStatus in
                                        Task {
                                            await viewModel.changeTaskStatus(taskId: task.id, status: newStatus)
                                        }
                                    }
                                )
                                .padding(.horizontal, AppSpacing.screenHorizontal)
                            }
                        }
                        .padding(.bottom, 120)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
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
            await viewModel.loadCategories()
            await viewModel.loadTasks()
        }
    }

    private func filterChip(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppTypography.captionMedium)
                .foregroundColor(isActive ? AppColors.magenta500 : AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.md)
                .background(
                    isActive
                    ? (colorScheme == .dark ? AppColors.magenta950 : AppColors.magenta50)
                    : (colorScheme == .dark ? AppColors.gray800 : .white)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(
                            isActive ? AppColors.magenta500 : (colorScheme == .dark ? AppColors.gray700 : AppColors.gray200),
                            lineWidth: 1
                        )
                )
        }
    }
}
