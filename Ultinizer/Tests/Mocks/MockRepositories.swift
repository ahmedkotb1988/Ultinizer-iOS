import Foundation
@testable import Ultinizer

final class MockAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    var loginResult: LoginResult?
    var loginError: Error?
    var registerResult: LoginResult?
    var registerError: Error?
    var logoutCalled = false
    var getMeResult: User?
    var getMeError: Error?
    var forgotPasswordCalled = false
    var changePasswordError: Error?

    func login(email: String, password: String) async throws -> LoginResult {
        if let error = loginError { throw error }
        guard let result = loginResult else { throw APIError.unknown("No mock") }
        return result
    }

    func register(input: RegisterInput) async throws -> LoginResult {
        if let error = registerError { throw error }
        guard let result = registerResult else { throw APIError.unknown("No mock") }
        return result
    }

    func logout() async throws { logoutCalled = true }

    func getMe() async throws -> User {
        if let error = getMeError { throw error }
        guard let result = getMeResult else { throw APIError.unknown("No mock") }
        return result
    }

    func updateMe(displayName: String?, roleLabel: String?) async throws -> User {
        guard let result = getMeResult else { throw APIError.unknown("No mock") }
        return result
    }

    func uploadAvatar(imageData: Data, fileName: String, mimeType: String) async throws -> String {
        "/uploads/avatar.jpg"
    }

    func forgotPassword(email: String) async throws { forgotPasswordCalled = true }

    func resetPassword(token: String, password: String) async throws {}

    func changePassword(currentPassword: String, newPassword: String) async throws {
        if let error = changePasswordError { throw error }
    }
}

final class MockTaskRepository: TaskRepositoryProtocol, @unchecked Sendable {
    var tasks: [HouseholdTask] = []
    var createError: Error?
    var deleteTaskCalled = false

    func getTasks(filters: TaskFilters) async throws -> TaskListResult {
        TaskListResult(tasks: tasks, cursor: nil, hasMore: false)
    }

    func getTask(id: String) async throws -> HouseholdTask {
        guard let task = tasks.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return task
    }

    func createTask(input: CreateTaskInput) async throws -> HouseholdTask {
        if let error = createError { throw error }
        return tasks.first ?? makeTestTask()
    }

    func updateTask(id: String, input: UpdateTaskInput) async throws -> HouseholdTask {
        guard let task = tasks.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return task
    }

    func deleteTask(id: String) async throws { deleteTaskCalled = true }

    func reorderTasks(tasks: [(id: String, sortOrder: Int)]) async throws {}

    func getTemplates() async throws -> [HouseholdTask] { [] }
}

func makeTestUser(id: String = "user1") -> User {
    User(
        id: id,
        email: "test@example.com",
        displayName: "Test User",
        avatarUrl: nil,
        roleLabel: "Tester",
        householdId: "hh1",
        createdAt: Date(),
        updatedAt: Date()
    )
}

func makeTestHousehold() -> Household {
    Household(
        id: "hh1",
        name: "Test Home",
        inviteCode: "ABC123",
        createdAt: Date(),
        updatedAt: Date(),
        members: [makeTestUser()]
    )
}

func makeTestTask(id: String = "task1") -> HouseholdTask {
    HouseholdTask(
        id: id,
        title: "Test Task",
        description: "A test task",
        categoryId: "cat1",
        category: TaskCategory(id: "cat1", name: "Chores", householdId: "hh1", isDefault: true, color: nil, icon: nil, createdAt: Date()),
        priority: .medium,
        status: .todo,
        assignmentType: .individual,
        dueDate: Date().addingTimeInterval(86400),
        estimatedMinutes: 30,
        householdId: "hh1",
        createdById: "user1",
        createdBy: makeTestUser(),
        assignees: [TaskAssignee(userId: "user1", taskId: id, user: makeTestUser())],
        subtasks: [
            Subtask(id: "st1", taskId: id, title: "Sub 1", isCompleted: false, sortOrder: 0, createdAt: Date()),
            Subtask(id: "st2", taskId: id, title: "Sub 2", isCompleted: true, sortOrder: 1, createdAt: Date()),
        ],
        attachments: [],
        comments: [],
        recurrence: nil,
        isTemplate: false,
        templateId: nil,
        sortOrder: 0,
        createdAt: Date(),
        updatedAt: Date(),
        completedAt: nil,
        verifiedAt: nil,
        verifiedById: nil
    )
}
