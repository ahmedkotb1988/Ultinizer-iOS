import SwiftUI

struct TaskDetailScreen: View {
    let taskId: String
    @State private var viewModel: TaskDetailViewModel
    @State private var commentText = ""
    @State private var showDeleteAlert = false
    @State private var deleteCommentId: String?
    @State private var reportTargetId: String?
    @State private var reportTargetType: ReportTargetType?
    @State private var showReportReasonSheet = false
    @State private var showReportDescriptionAlert = false
    @State private var reportDescription = ""
    @State private var selectedReportReason: ReportReason?
    @State private var showReportConfirmation = false
    @State private var reportError = ""

    private let router: AppRouter
    private let container: AppContainer
    private let authManager: AuthManager

    @Environment(\.colorScheme) private var colorScheme

    init(taskId: String, container: AppContainer, router: AppRouter, authManager: AuthManager) {
        self.taskId = taskId
        self.container = container
        self.router = router
        self.authManager = authManager
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
                .accessibilityLabel("Go back")
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
                        .accessibilityLabel("Edit task")
                        Button(action: { showDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .font(.system(size: 22))
                                .foregroundColor(AppColors.red500)
                        }
                        .accessibilityLabel("Delete task")
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
                            .accessibilityAddTraits(.isHeader)

                        // Meta badges
                        HStack(spacing: AppSpacing.md) {
                            PriorityBadge(priority: task.priority)
                                .accessibilityLabel("Priority: \(task.priority.displayName)")
                            if let category = task.category {
                                BadgeView(label: category.name, color: .gray)
                                    .accessibilityLabel("Category: \(category.name)")
                            }
                            if task.assignmentType == .shared {
                                BadgeView(label: "Shared", color: .magenta)
                                    .accessibilityLabel("Assignment: Shared")
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
                                        .accessibilityAddTraits(.isHeader)
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

                        // Attachments
                        if !task.attachments.isEmpty {
                            attachmentsSection(attachments: task.attachments)
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
        .confirmationDialog("Report Content", isPresented: $showReportReasonSheet, titleVisibility: .visible) {
            ForEach(ReportReason.allCases, id: \.self) { reason in
                Button(reason.displayName) {
                    selectedReportReason = reason
                    if reason == .other {
                        showReportDescriptionAlert = true
                    } else {
                        Task { await submitReport(reason: reason, description: nil) }
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                reportTargetId = nil
                reportTargetType = nil
            }
        }
        .alert("Describe the issue", isPresented: $showReportDescriptionAlert) {
            TextField("Description", text: $reportDescription)
            Button("Cancel", role: .cancel) {
                reportDescription = ""
                reportTargetId = nil
                reportTargetType = nil
            }
            Button("Submit") {
                if let reason = selectedReportReason {
                    let desc = reportDescription.isEmpty ? nil : reportDescription
                    Task { await submitReport(reason: reason, description: desc) }
                }
                reportDescription = ""
            }
        } message: {
            Text("Please describe why you are reporting this content.")
        }
        .alert("Report Submitted", isPresented: $showReportConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Report submitted. We'll review this within 24 hours.")
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
                    .accessibilityAddTraits(.isHeader)
                HStack(spacing: AppSpacing.md) {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        Button(action: {
                            Task { await viewModel.changeStatus(status) }
                        }) {
                            VStack(spacing: AppSpacing.xs) {
                                Image(systemName: status.iconName)
                                    .font(.system(size: 18))
                                    .accessibilityHidden(true)
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
                        .accessibilityLabel("Set status to \(status.displayName)\(task.status == status ? ", currently selected" : "")")
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
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Due Date")
                        .font(AppTypography.labelSemiBold)
                        .foregroundColor(AppColors.textSecondary)
                    Text(dueDate.formatted(date: .complete, time: .shortened))
                        .font(AppTypography.label)
                        .foregroundColor(isOverdue ? AppColors.red500 : AppColors.textSecondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Due date: \(dueDate.formatted(date: .complete, time: .shortened))\(isOverdue ? ", overdue" : "")")
        }
    }

    private func assigneesCard(assignees: [TaskAssignee]) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Assigned To")
                    .font(AppTypography.labelSemiBold)
                    .foregroundColor(AppColors.textSecondary)
                    .accessibilityAddTraits(.isHeader)
                ForEach(assignees, id: \.userId) { assignee in
                    HStack(spacing: AppSpacing.md) {
                        AvatarView(name: assignee.user?.displayName ?? "?", size: .sm)
                            .accessibilityHidden(true)
                        Text(assignee.user?.displayName ?? "Unknown")
                            .font(AppTypography.label)
                            .foregroundColor(AppColors.textSecondary)
                        if let role = assignee.user?.roleLabel, !role.isEmpty {
                            Text("(\(role))")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.gray400)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Assigned to \(assignee.user?.displayName ?? "Unknown")")
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
                    .accessibilityLabel("Subtasks: \(completed) of \(subtasks.count) completed")
                    .accessibilityAddTraits(.isHeader)
                ForEach(sorted) { subtask in
                    Button(action: {
                        Task { await viewModel.toggleSubtask(subtask) }
                    }) {
                        HStack(spacing: AppSpacing.md) {
                            Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20))
                                .foregroundColor(subtask.isCompleted ? AppColors.green500 : AppColors.gray400)
                                .accessibilityHidden(true)
                            Text(subtask.title)
                                .font(AppTypography.label)
                                .foregroundColor(subtask.isCompleted ? AppColors.gray400 : AppColors.textSecondary)
                                .strikethrough(subtask.isCompleted)
                        }
                        .opacity(viewModel.togglingSubtasks.contains(subtask.id) ? 0.5 : 1)
                    }
                    .disabled(viewModel.togglingSubtasks.contains(subtask.id))
                    .accessibilityLabel("\(subtask.title), \(subtask.isCompleted ? "completed" : "not completed")")
                    .accessibilityHint("Double tap to toggle completion")
                }
            }
        }
    }

    private func attachmentsSection(attachments: [Attachment]) -> some View {
        let imageAttachments = attachments.filter { $0.isImage }
        return Group {
            if !imageAttachments.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Text("Attachments (\(imageAttachments.count))")
                        .font(AppTypography.bodySemiBold)
                        .foregroundColor(AppColors.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.md) {
                            ForEach(imageAttachments) { attachment in
                                let imageURL = URL(string: container.baseURL.absoluteString + attachment.url)
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .foregroundColor(AppColors.gray400)
                                    case .empty:
                                        ProgressView()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                                .accessibilityLabel("Task attachment photo: \(attachment.originalName)")
                                .contextMenu {
                                    if attachment.uploadedById != authManager.user?.id {
                                        Button(action: {
                                            reportTargetId = attachment.id
                                            reportTargetType = .attachment
                                            showReportReasonSheet = true
                                        }) {
                                            Label("Report", systemImage: "exclamationmark.triangle")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Comments (\(viewModel.comments.count))")
                .font(AppTypography.bodySemiBold)
                .foregroundColor(AppColors.textPrimary)
                .accessibilityLabel("Comments: \(viewModel.comments.count)")
                .accessibilityAddTraits(.isHeader)

            ForEach(viewModel.rootComments) { comment in
                commentItem(comment, level: 0)
                ForEach(viewModel.childComments(for: comment.id)) { reply in
                    commentItem(reply, level: 1)
                }
            }
        }
    }

    private func commentItem(_ comment: Comment, level: Int) -> some View {
        let isOwnComment = comment.authorId == authManager.user?.id
        return VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.md) {
                AvatarView(name: comment.author?.displayName ?? "?", size: .sm)
                    .accessibilityHidden(true)
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
                .accessibilityLabel("Reply to \(comment.author?.displayName ?? "comment")")

                if isOwnComment {
                    Button(action: { deleteCommentId = comment.id }) {
                        Text("Delete")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.gray400)
                    }
                    .accessibilityLabel("Delete comment")
                } else {
                    Button(action: {
                        reportTargetId = comment.id
                        reportTargetType = .comment
                        showReportReasonSheet = true
                    }) {
                        Text("Report")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.gray400)
                    }
                    .accessibilityLabel("Report comment by \(comment.author?.displayName ?? "unknown")")
                }
            }
        }
        .padding(.leading, CGFloat(level) * 24)
        .padding(.bottom, AppSpacing.md)
        .accessibilityElement(children: .contain)
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
                    .accessibilityLabel("Cancel reply")
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
                    .accessibilityLabel("Comment text field")

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
                .accessibilityLabel("Send comment")
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.md)
            .background(colorScheme == .dark ? AppColors.gray800 : .white)
        }
    }

    // MARK: - Report

    @MainActor
    private func submitReport(reason: ReportReason, description: String?) async {
        guard let targetId = reportTargetId, let targetType = reportTargetType else { return }
        do {
            try await container.reportRepository.createReport(
                targetType: targetType,
                targetId: targetId,
                reason: reason,
                description: description
            )
            showReportConfirmation = true
        } catch {
            reportError = "Failed to submit report"
        }
        reportTargetId = nil
        reportTargetType = nil
        selectedReportReason = nil
    }
}
