import SwiftUI

struct CreateTaskScreen: View {
    @State private var viewModel: CreateTaskViewModel
    private let authManager: AuthManager
    private let router: AppRouter

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    init(container: AppContainer, authManager: AuthManager, router: AppRouter) {
        self.authManager = authManager
        self.router = router
        _viewModel = State(initialValue: CreateTaskViewModel(
            createTaskUseCase: container.createTaskUseCase,
            categoryRepository: container.categoryRepository
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 4)

            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.gray400)
                }
                Spacer()
                Text("New Task")
                    .font(AppTypography.heading)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Color.clear.frame(width: 20)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.md)
            .overlay(Divider().foregroundColor(AppColors.borderPrimary), alignment: .bottom)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if viewModel.hasError {
                        ErrorBanner(message: viewModel.errorMessage)
                            .padding(.bottom, AppSpacing.xl)
                    }

                    // Title
                    TextInput(
                        label: "Title",
                        placeholder: "What needs to be done?",
                        text: $viewModel.title
                    )

                    // Description
                    TextInput(
                        label: "Description (optional)",
                        placeholder: "Add details...",
                        text: $viewModel.description,
                        isMultiline: true
                    )

                    // Priority
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Priority")
                            .font(AppTypography.labelMedium)
                            .foregroundColor(colorScheme == .dark ? AppColors.gray300 : AppColors.gray700)

                        HStack(spacing: AppSpacing.md) {
                            ForEach(TaskPriority.allCases, id: \.self) { p in
                                priorityButton(p)
                            }
                        }
                    }
                    .padding(.bottom, AppSpacing.xl)

                    // Category
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Category")
                            .font(AppTypography.labelMedium)
                            .foregroundColor(colorScheme == .dark ? AppColors.gray300 : AppColors.gray700)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.md) {
                                ForEach(viewModel.categories) { cat in
                                    categoryChip(cat)
                                }
                            }
                        }
                    }
                    .padding(.bottom, AppSpacing.xl)

                    // Assignees
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Assign To")
                            .font(AppTypography.labelMedium)
                            .foregroundColor(colorScheme == .dark ? AppColors.gray300 : AppColors.gray700)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: AppSpacing.md) {
                            ForEach(viewModel.members) { member in
                                assigneeChip(member)
                            }
                        }
                    }
                    .padding(.bottom, AppSpacing.xl)

                    // Due date
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Due Date (optional)")
                            .font(AppTypography.labelMedium)
                            .foregroundColor(colorScheme == .dark ? AppColors.gray300 : AppColors.gray700)

                        Button(action: { viewModel.showDatePicker.toggle() }) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(AppColors.gray400)
                                Text(viewModel.dueDate?.formatted(date: .abbreviated, time: .omitted) ?? "Set due date")
                                    .font(AppTypography.body)
                                    .foregroundColor(viewModel.dueDate != nil ? AppColors.textPrimary : AppColors.textTertiary)
                                Spacer()
                                if viewModel.dueDate != nil {
                                    Button(action: { viewModel.dueDate = nil }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(AppColors.gray400)
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.xl)
                            .padding(.vertical, AppSpacing.lg)
                            .background(colorScheme == .dark ? AppColors.gray800 : .white)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.lg)
                                    .stroke(colorScheme == .dark ? AppColors.gray700 : AppColors.gray200, lineWidth: 1)
                            )
                        }

                        if viewModel.showDatePicker {
                            DatePicker(
                                "Due Date",
                                selection: Binding(
                                    get: { viewModel.dueDate ?? Date() },
                                    set: { viewModel.dueDate = $0 }
                                ),
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.graphical)
                            .tint(AppColors.magenta500)
                        }
                    }
                    .padding(.bottom, AppSpacing.xl)

                    // Subtasks
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Text("Subtasks")
                                .font(AppTypography.labelMedium)
                                .foregroundColor(colorScheme == .dark ? AppColors.gray300 : AppColors.gray700)
                            Spacer()
                            Button(action: { viewModel.addSubtask() }) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(AppColors.magenta500)
                            }
                        }

                        ForEach(viewModel.subtaskTitles.indices, id: \.self) { index in
                            HStack(spacing: AppSpacing.md) {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(AppColors.gray400)
                                TextField("Subtask \(index + 1)", text: $viewModel.subtaskTitles[index])
                                    .font(AppTypography.body)
                                    .padding(.horizontal, AppSpacing.xl)
                                    .padding(.vertical, AppSpacing.lg)
                                    .background(colorScheme == .dark ? AppColors.gray800 : .white)
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppRadius.lg)
                                            .stroke(colorScheme == .dark ? AppColors.gray700 : AppColors.gray200, lineWidth: 1)
                                    )
                                Button(action: { viewModel.removeSubtask(at: index) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppColors.red500)
                                }
                            }
                        }
                    }
                    .padding(.bottom, AppSpacing.xl)

                    // Estimated time
                    TextInput(
                        label: "Estimated Time (minutes)",
                        placeholder: "e.g. 30",
                        text: $viewModel.estimatedMinutes,
                        keyboardType: .numberPad
                    )

                    // Submit
                    AppButton(
                        "Create Task",
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            if await viewModel.createTask() {
                                dismiss()
                            }
                        }
                    }
                    .padding(.bottom, AppSpacing.huge)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(AppColors.backgroundSecondary)
        .presentationDragIndicator(.hidden)
        .task {
            await viewModel.loadFormData(household: authManager.household)
        }
    }

    // MARK: - Components

    private func priorityButton(_ p: TaskPriority) -> some View {
        let isSelected = viewModel.priority == p
        let priorityColor: Color = {
            switch p {
            case .low: return AppColors.blue500
            case .medium: return AppColors.yellow500
            case .high: return AppColors.orange500
            case .urgent: return AppColors.red500
            }
        }()

        return Button(action: { viewModel.priority = p }) {
            VStack(spacing: AppSpacing.xs) {
                Circle()
                    .fill(priorityColor)
                    .frame(width: 12, height: 12)
                Text(p.displayName)
                    .font(AppTypography.captionMedium)
                    .foregroundColor(isSelected ? AppColors.magenta500 : AppColors.gray500)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.mdPlus)
            .background(
                isSelected
                ? (colorScheme == .dark ? AppColors.magenta950 : AppColors.magenta50)
                : .clear
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(
                        isSelected ? AppColors.magenta500 : (colorScheme == .dark ? AppColors.gray700 : AppColors.gray200),
                        lineWidth: 1
                    )
            )
        }
    }

    private func categoryChip(_ cat: TaskCategory) -> some View {
        let isSelected = viewModel.selectedCategoryId == cat.id
        return Button(action: { viewModel.selectedCategoryId = cat.id }) {
            Text(cat.name)
                .font(AppTypography.labelMedium)
                .foregroundColor(isSelected ? AppColors.magenta500 : AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.md)
                .background(
                    isSelected
                    ? (colorScheme == .dark ? AppColors.magenta950 : AppColors.magenta50)
                    : .clear
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(
                            isSelected ? AppColors.magenta500 : (colorScheme == .dark ? AppColors.gray700 : AppColors.gray200),
                            lineWidth: 1
                        )
                )
        }
    }

    private func assigneeChip(_ member: User) -> some View {
        let isSelected = viewModel.selectedAssigneeIds.contains(member.id)
        return Button(action: {
            if isSelected {
                viewModel.selectedAssigneeIds.remove(member.id)
            } else {
                viewModel.selectedAssigneeIds.insert(member.id)
            }
        }) {
            Text(member.displayName)
                .font(AppTypography.labelMedium)
                .foregroundColor(isSelected ? AppColors.magenta500 : AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.md)
                .background(
                    isSelected
                    ? (colorScheme == .dark ? AppColors.magenta950 : AppColors.magenta50)
                    : .clear
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(
                            isSelected ? AppColors.magenta500 : (colorScheme == .dark ? AppColors.gray700 : AppColors.gray200),
                            lineWidth: 1
                        )
                )
        }
    }
}
