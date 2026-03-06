import SwiftUI

struct TaskDetailScreen: View {
    let taskId: String
    @State private var viewModel: TaskDetailViewModel
    @State private var commentText = ""
    @State private var showDeleteAlert = false
    @State private var deleteCommentId: String?

    private let router: AppRouter
    private let container: AppContainer

    @Environment(\.colorScheme) private var colorScheme

    init(taskId: String, container: AppContainer, router: AppRouter) {
        self.taskId = taskId
        self.container = container
        self.router = router
        _viewModel = State(initialValue: TaskDetailViewModel(
            getTaskUseCase: container.getTaskUseCase,
            updateTaskUseCase: container.updateTaskUseCase,
            deleteTaskUseCase: container.deleteTaskUseCase,
            getCommentsUseCase: container.getCommentsUseCase,
            createCommentUseCase: container.createCommentUseCase,
            deleteCommentUseCase: container.deleteCommentUseCase,
            subtaskRepository: container.subtaskRepository
        ))
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
                Spacer()
                if viewModel.task != nil {
                    HStack(spacing: AppSpacing.lg) {
                        Button(action: {
                            router.navigate(to: .editTask(id: taskId))
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 22))
                                .foregroundColor(AppColors.gray400)
                        }
                        Button(action: { showDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .font(.system(size: 22))
                                .foregroundColor(AppColors.red500)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.lg)
            .overlay(
                Divider().foregroundColor(AppColors.borderPrimary),
                alignment: .bottom
            )

            if viewModel.isLoading || viewModel.task == nil {
                VStack {
                    TaskSkeletonView()
                    TaskSkeletonView()
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.xl)
                Spacer()
            } else if let task = viewModel.task {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Title
                        Text(task.title)
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.bottom, AppSpacing.md)

                        // Meta badges
                        HStack(spacing: AppSpacing.md) {
                            PriorityBadge(priority: task.priority)
                            if let category = task.category {
                                BadgeView(label: category.name, color: .gray)
                            }
                            if task.assignmentType == .shared {
                                BadgeView(label: "Shared", color: .magenta)
                            }
                        }
                        .padding(.bottom, AppSpacing.xl)

                        // Status selector
                        statusSelector(task: task)
                            .padding(.bottom, AppSpacing.xl)

                        // Description
                        if let desc = task.description, !desc.isEmpty {
                            CardView {
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Description")
                                        .font(AppTypography.labelSemiBold)
                                        .foregroundColor(AppColors.textSecondary)
                                    Text(desc)
                                        .font(AppTypography.label)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            .padding(.bottom, AppSpacing.xl)
                        }

                        // Due date
                        if let dueDate = task.dueDate {
                            dueDateCard(dueDate: dueDate, isOverdue: viewModel.isOverdue)
                                .padding(.bottom, AppSpacing.xl)
                        }

                        // Assignees
                        if !task.assignees.isEmpty {
                            assigneesCard(assignees: task.assignees)
                                .padding(.bottom, AppSpacing.xl)
                        }

                        // Subtasks
                        if !task.subtasks.isEmpty {
                            subtasksCard(subtasks: task.subtasks)
                                .padding(.bottom, AppSpacing.xl)
                        }

                        // Comments
                        commentsSection
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.xxl)
                }

                // Comment input
                commentInputBar
            }
        }
        .background(AppColors.backgroundSecondary)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Delete Task", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteTask() {
                        router.pop()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this task?")
        }
        .alert("Delete Comment", isPresented: .init(
            get: { deleteCommentId != nil },
            set: { if !$0 { deleteCommentId = nil } }
        )) {
            Button("Cancel", role: .cancel) { deleteCommentId = nil }
            Button("Delete", role: .destructive) {
                if let id = deleteCommentId {
                    Task { await viewModel.deleteComment(commentId: id) }
                }
                deleteCommentId = nil
            }
        }
        .task {
            await viewModel.loadTask(id: taskId)
        }
    }

    // MARK: - Subviews

    private func statusSelector(task: HouseholdTask) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Status")
                    .font(AppTypography.labelSemiBold)
                    .foregroundColor(AppColors.textSecondary)
                HStack(spacing: AppSpacing.md) {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        Button(action: {
                            Task { await viewModel.changeStatus(status) }
                        }) {
                            VStack(spacing: AppSpacing.xs) {
                                Image(systemName: status.iconName)
                                    .font(.system(size: 18))
                                Text(status.displayName)
                                    .font(AppTypography.captionMedium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.mdPlus)
                            .foregroundColor(task.status == status ? AppColors.magenta500 : AppColors.gray500)
                            .background(
                                task.status == status
                                ? (colorScheme == .dark ? AppColors.magenta950 : AppColors.magenta50)
                                : .clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .stroke(
                                        task.status == status ? AppColors.magenta500 : (colorScheme == .dark ? AppColors.gray700 : AppColors.gray200),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                }
            }
        }
    }

    private func dueDateCard(dueDate: Date, isOverdue: Bool) -> some View {
        CardView {
            HStack(spacing: AppSpacing.lg) {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(isOverdue ? AppColors.red500 : AppColors.magenta500)
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Due Date")
                        .font(AppTypography.labelSemiBold)
                        .foregroundColor(AppColors.textSecondary)
                    Text(dueDate.formatted(date: .complete, time: .shortened))
                        .font(AppTypography.label)
                        .foregroundColor(isOverdue ? AppColors.red500 : AppColors.textSecondary)
                }
            }
        }
    }

    private func assigneesCard(assignees: [TaskAssignee]) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Assigned To")
                    .font(AppTypography.labelSemiBold)
                    .foregroundColor(AppColors.textSecondary)
                ForEach(assignees, id: \.userId) { assignee in
                    HStack(spacing: AppSpacing.md) {
                        AvatarView(name: assignee.user?.displayName ?? "?", size: .sm)
                        Text(assignee.user?.displayName ?? "Unknown")
                            .font(AppTypography.label)
                            .foregroundColor(AppColors.textSecondary)
                        if let role = assignee.user?.roleLabel, !role.isEmpty {
                            Text("(\(role))")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.gray400)
                        }
                    }
                }
            }
        }
    }

    private func subtasksCard(subtasks: [Subtask]) -> some View {
        let sorted = subtasks.sorted { $0.sortOrder < $1.sortOrder }
        let completed = subtasks.filter(\.isCompleted).count
        return CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Subtasks (\(completed)/\(subtasks.count))")
                    .font(AppTypography.labelSemiBold)
                    .foregroundColor(AppColors.textSecondary)
                ForEach(sorted) { subtask in
                    Button(action: {
                        Task { await viewModel.toggleSubtask(subtask) }
                    }) {
                        HStack(spacing: AppSpacing.md) {
                            Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20))
                                .foregroundColor(subtask.isCompleted ? AppColors.green500 : AppColors.gray400)
                            Text(subtask.title)
                                .font(AppTypography.label)
                                .foregroundColor(subtask.isCompleted ? AppColors.gray400 : AppColors.textSecondary)
                                .strikethrough(subtask.isCompleted)
                        }
                        .opacity(viewModel.togglingSubtasks.contains(subtask.id) ? 0.5 : 1)
                    }
                    .disabled(viewModel.togglingSubtasks.contains(subtask.id))
                }
            }
        }
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Comments (\(viewModel.comments.count))")
                .font(AppTypography.bodySemiBold)
                .foregroundColor(AppColors.textPrimary)

            ForEach(viewModel.rootComments) { comment in
                commentItem(comment, level: 0)
                ForEach(viewModel.childComments(for: comment.id)) { reply in
                    commentItem(reply, level: 1)
                }
            }
        }
    }

    private func commentItem(_ comment: Comment, level: Int) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.md) {
                AvatarView(name: comment.author?.displayName ?? "?", size: .sm)
                VStack(alignment: .leading, spacing: 2) {
                    Text(comment.author?.displayName ?? "Unknown")
                        .font(AppTypography.labelSemiBold)
                        .foregroundColor(AppColors.textPrimary)
                    Text(comment.createdAt.formatted(.relative(presentation: .named)))
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.gray400)
                }
                Spacer()
            }
            Text(comment.content)
                .font(AppTypography.label)
                .foregroundColor(AppColors.textSecondary)

            HStack(spacing: AppSpacing.xl) {
                Button(action: { viewModel.replyTo = comment }) {
                    Text("Reply")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.gray400)
                }
                Button(action: { deleteCommentId = comment.id }) {
                    Text("Delete")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.gray400)
                }
            }
        }
        .padding(.leading, CGFloat(level) * 24)
        .padding(.bottom, AppSpacing.md)
    }

    private var commentInputBar: some View {
        VStack(spacing: 0) {
            if let replyTo = viewModel.replyTo {
                HStack {
                    Text("Replying to \(replyTo.author?.displayName ?? "...")")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.gray400)
                    Spacer()
                    Button(action: { viewModel.replyTo = nil }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.gray400)
                    }
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.xs)
            }

            Divider().foregroundColor(AppColors.borderPrimary)

            HStack(spacing: AppSpacing.md) {
                TextField("Write a comment...", text: $commentText)
                    .font(AppTypography.label)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.vertical, AppSpacing.lg)
                    .background(colorScheme == .dark ? AppColors.gray700 : AppColors.gray100)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))

                Button(action: {
                    guard !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    let text = commentText
                    commentText = ""
                    Task { await viewModel.submitComment(content: text) }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(
                            commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? AppColors.gray300
                            : AppColors.magenta500
                        )
                }
                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.md)
            .background(colorScheme == .dark ? AppColors.gray800 : .white)
        }
    }
}
