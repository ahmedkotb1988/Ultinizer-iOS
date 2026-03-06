import XCTest
@testable import Ultinizer

final class TaskMapperTests: XCTestCase {
    func testMapTaskDTO() {
        let categoryDTO = TaskCategoryDTO(
            id: "cat1", name: "Chores", householdId: "hh1",
            isDefault: true, color: nil, icon: nil, createdAt: Date()
        )

        let assigneeDTO = TaskAssigneeDTO(
            userId: "u1", taskId: "t1",
            user: UserDTO(
                id: "u1", email: "a@b.com", displayName: "User",
                avatarUrl: nil, roleLabel: nil, householdId: "hh1",
                createdAt: Date(), updatedAt: Date()
            )
        )

        let subtaskDTO = SubtaskDTO(
            id: "st1", taskId: "t1", title: "Sub 1",
            isCompleted: true, sortOrder: 0, createdAt: Date()
        )

        let dto = TaskDTO(
            id: "t1", title: "Test Task", description: "Description",
            categoryId: "cat1", category: categoryDTO,
            priority: "high", status: "in_progress",
            assignmentType: "shared",
            dueDate: Date(), estimatedMinutes: 45,
            householdId: "hh1", createdById: "u1",
            createdBy: nil,
            assignees: [assigneeDTO],
            subtasks: [subtaskDTO],
            attachments: nil, comments: nil,
            recurrence: nil,
            isTemplate: false, templateId: nil,
            sortOrder: 0,
            createdAt: Date(), updatedAt: Date(),
            completedAt: nil, verifiedAt: nil, verifiedById: nil
        )

        let task = TaskMapper.map(dto)

        XCTAssertEqual(task.id, "t1")
        XCTAssertEqual(task.title, "Test Task")
        XCTAssertEqual(task.description, "Description")
        XCTAssertEqual(task.priority, .high)
        XCTAssertEqual(task.status, .inProgress)
        XCTAssertEqual(task.assignmentType, .shared)
        XCTAssertEqual(task.estimatedMinutes, 45)
        XCTAssertEqual(task.assignees.count, 1)
        XCTAssertEqual(task.subtasks.count, 1)
        XCTAssertTrue(task.subtasks.first?.isCompleted ?? false)
        XCTAssertEqual(task.category?.name, "Chores")
    }

    func testMapTaskDTOWithUnknownPriority() {
        let dto = TaskDTO(
            id: "t1", title: "Task", description: nil,
            categoryId: "cat1", category: nil,
            priority: "unknown_value", status: "todo",
            assignmentType: nil,
            dueDate: nil, estimatedMinutes: nil,
            householdId: "hh1", createdById: "u1",
            createdBy: nil, assignees: nil, subtasks: nil,
            attachments: nil, comments: nil, recurrence: nil,
            isTemplate: nil, templateId: nil, sortOrder: nil,
            createdAt: Date(), updatedAt: Date(),
            completedAt: nil, verifiedAt: nil, verifiedById: nil
        )

        let task = TaskMapper.map(dto)
        XCTAssertEqual(task.priority, .medium) // fallback
        XCTAssertEqual(task.status, .todo)
        XCTAssertTrue(task.subtasks.isEmpty)
        XCTAssertTrue(task.assignees.isEmpty)
    }
}
