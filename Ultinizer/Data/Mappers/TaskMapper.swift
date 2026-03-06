import Foundation

struct TaskMapper {
    static func map(_ dto: TaskDTO) -> HouseholdTask {
        HouseholdTask(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            categoryId: dto.categoryId,
            category: dto.category.map(CategoryMapper.map),
            priority: TaskPriority(rawValue: dto.priority) ?? .medium,
            status: TaskStatus(rawValue: dto.status) ?? .todo,
            assignmentType: AssignmentType(rawValue: dto.assignmentType ?? "individual") ?? .individual,
            dueDate: dto.dueDate,
            estimatedMinutes: dto.estimatedMinutes,
            householdId: dto.householdId,
            createdById: dto.createdById,
            createdBy: dto.createdBy.map(UserMapper.map),
            assignees: (dto.assignees ?? []).map(mapAssignee),
            subtasks: (dto.subtasks ?? []).map(SubtaskMapper.map),
            attachments: (dto.attachments ?? []).map(AttachmentMapper.map),
            comments: (dto.comments ?? []).map(CommentMapper.map),
            recurrence: dto.recurrence.map(mapRecurrence),
            isTemplate: dto.isTemplate ?? false,
            templateId: dto.templateId,
            sortOrder: dto.sortOrder ?? 0,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            completedAt: dto.completedAt,
            verifiedAt: dto.verifiedAt,
            verifiedById: dto.verifiedById
        )
    }

    static func mapAssignee(_ dto: TaskAssigneeDTO) -> TaskAssignee {
        TaskAssignee(
            userId: dto.userId,
            taskId: dto.taskId,
            user: dto.user.map(UserMapper.map)
        )
    }

    static func mapRecurrence(_ dto: TaskRecurrenceDTO) -> TaskRecurrence {
        TaskRecurrence(
            type: RecurrenceType(rawValue: dto.type) ?? .daily,
            interval: dto.interval,
            daysOfWeek: dto.daysOfWeek,
            dayOfMonth: dto.dayOfMonth,
            cronExpression: dto.cronExpression
        )
    }
}

struct SubtaskMapper {
    static func map(_ dto: SubtaskDTO) -> Subtask {
        Subtask(
            id: dto.id,
            taskId: dto.taskId,
            title: dto.title,
            isCompleted: dto.isCompleted,
            sortOrder: dto.sortOrder,
            createdAt: dto.createdAt
        )
    }
}

struct CategoryMapper {
    static func map(_ dto: TaskCategoryDTO) -> TaskCategory {
        TaskCategory(
            id: dto.id,
            name: dto.name,
            householdId: dto.householdId,
            isDefault: dto.isDefault ?? false,
            color: dto.color,
            icon: dto.icon,
            createdAt: dto.createdAt
        )
    }
}

struct AttachmentMapper {
    static func map(_ dto: AttachmentDTO) -> Attachment {
        Attachment(
            id: dto.id,
            taskId: dto.taskId,
            commentId: dto.commentId,
            filename: dto.filename,
            originalName: dto.originalName,
            mimeType: dto.mimeType,
            size: dto.size,
            url: dto.url,
            thumbnailUrl: dto.thumbnailUrl,
            uploadedById: dto.uploadedById,
            createdAt: dto.createdAt
        )
    }
}

struct CommentMapper {
    static func map(_ dto: CommentDTO) -> Comment {
        Comment(
            id: dto.id,
            taskId: dto.taskId,
            authorId: dto.authorId,
            author: dto.author.map(UserMapper.map),
            content: dto.content,
            parentId: dto.parentId,
            isEdited: dto.isEdited ?? false,
            attachments: (dto.attachments ?? []).map(AttachmentMapper.map),
            seenBy: (dto.seenBy ?? []).map(mapCommentSeen),
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt
        )
    }

    static func mapCommentSeen(_ dto: CommentSeenDTO) -> CommentSeen {
        CommentSeen(userId: dto.userId, commentId: dto.commentId, seenAt: dto.seenAt)
    }
}

struct NotificationMapper {
    static func map(_ dto: NotificationDTO) -> AppNotification {
        AppNotification(
            id: dto.id,
            userId: dto.userId,
            type: NotificationType(rawValue: dto.type) ?? .taskAssigned,
            title: dto.title,
            body: dto.body,
            taskId: dto.taskId,
            commentId: dto.commentId,
            isRead: dto.isRead,
            createdAt: dto.createdAt
        )
    }
}

struct StatsMapper {
    static func mapDashboard(_ dto: DashboardStatsDTO) -> DashboardData {
        DashboardData(
            todayTasks: dto.todayTasks.map(TaskMapper.map),
            overdueTasks: dto.overdueTasks.map(TaskMapper.map),
            upcomingTasks: dto.upcomingTasks.map(TaskMapper.map),
            recentActivity: (dto.recentActivity ?? []).map {
                ActivityItem(type: $0.type, description: $0.description, createdAt: $0.createdAt)
            }
        )
    }

    static func mapOverview(_ dto: StatsOverviewDTO) -> StatsOverview {
        StatsOverview(
            completionRate: dto.completionRate,
            totalTasks: dto.totalTasks,
            completedTasks: dto.completedTasks,
            byCategory: (dto.byCategory ?? []).map {
                CategoryStat(categoryId: $0.categoryId, categoryName: $0.categoryName, count: $0.count)
            },
            byMember: (dto.byMember ?? []).map {
                MemberStat(userId: $0.userId, displayName: $0.displayName, total: $0.total, completed: $0.completed)
            },
            streak: StreakInfo(current: dto.streak?.current ?? 0, longest: dto.streak?.longest ?? 0),
            weeklyTrend: (dto.weeklyTrend ?? []).map {
                WeeklyTrendItem(date: $0.date, completed: $0.completed, created: $0.created)
            }
        )
    }
}
