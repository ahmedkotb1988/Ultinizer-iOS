import XCTest
@testable import Ultinizer

final class CreateTaskUseCaseTests: XCTestCase {
    var mockRepo: MockTaskRepository!
    var sut: CreateTaskUseCase!

    override func setUp() {
        super.setUp()
        mockRepo = MockTaskRepository()
        mockRepo.tasks = [makeTestTask()]
        sut = CreateTaskUseCase(taskRepository: mockRepo)
    }

    func testCreateTaskSuccess() async throws {
        let input = CreateTaskInput(
            title: "New Task",
            description: nil,
            categoryId: "cat1",
            priority: .medium,
            assignmentType: .individual,
            assigneeIds: ["user1"],
            dueDate: nil,
            estimatedMinutes: nil,
            isTemplate: false,
            templateId: nil,
            subtasks: [],
            recurrence: nil
        )

        let result = try await sut.execute(input: input)
        XCTAssertFalse(result.id.isEmpty)
    }

    func testCreateTaskEmptyTitle() async {
        let input = CreateTaskInput(
            title: "",
            description: nil,
            categoryId: "cat1",
            priority: .medium,
            assignmentType: .individual,
            assigneeIds: ["user1"],
            dueDate: nil,
            estimatedMinutes: nil,
            isTemplate: false,
            templateId: nil,
            subtasks: [],
            recurrence: nil
        )

        do {
            _ = try await sut.execute(input: input)
            XCTFail("Expected error")
        } catch {
            // Expected
        }
    }

    func testCreateTaskNoCategory() async {
        let input = CreateTaskInput(
            title: "Task",
            description: nil,
            categoryId: "",
            priority: .medium,
            assignmentType: .individual,
            assigneeIds: ["user1"],
            dueDate: nil,
            estimatedMinutes: nil,
            isTemplate: false,
            templateId: nil,
            subtasks: [],
            recurrence: nil
        )

        do {
            _ = try await sut.execute(input: input)
            XCTFail("Expected error")
        } catch {
            // Expected
        }
    }

    func testCreateTaskNoAssignees() async {
        let input = CreateTaskInput(
            title: "Task",
            description: nil,
            categoryId: "cat1",
            priority: .medium,
            assignmentType: .individual,
            assigneeIds: [],
            dueDate: nil,
            estimatedMinutes: nil,
            isTemplate: false,
            templateId: nil,
            subtasks: [],
            recurrence: nil
        )

        do {
            _ = try await sut.execute(input: input)
            XCTFail("Expected error")
        } catch {
            // Expected
        }
    }
}
