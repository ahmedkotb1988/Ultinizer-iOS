import Foundation
import Observation

@Observable
final class CreateTaskViewModel {
    var title = ""
    var description = ""
    var priority: TaskPriority = .medium
    var selectedCategoryId = ""
    var selectedAssigneeIds: Set<String> = []
    var dueDate: Date?
    var showDatePicker = false
    var estimatedMinutes: String = ""
    var subtaskTitles: [String] = []
    var isLoading = false
    var errorMessage = ""

    var categories: [TaskCategory] = []
    var members: [User] = []

    private let createTaskUseCase: CreateTaskUseCaseProtocol
    private let categoryRepository: CategoryRepositoryProtocol

    init(
        createTaskUseCase: CreateTaskUseCaseProtocol,
        categoryRepository: CategoryRepositoryProtocol
    ) {
        self.createTaskUseCase = createTaskUseCase
        self.categoryRepository = categoryRepository
    }

    var hasError: Bool { !errorMessage.isEmpty }

    @MainActor
    func loadFormData(household: Household?) async {
        do {
            categories = try await categoryRepository.getCategories()
        } catch {
            print("[CreateTaskVM] Failed to load categories: \(error)")
            errorMessage = "Failed to load categories. Please try again."
        }
        members = household?.members ?? []
    }

    func addSubtask() {
        subtaskTitles.append("")
    }

    func removeSubtask(at index: Int) {
        guard subtaskTitles.indices.contains(index) else { return }
        subtaskTitles.remove(at: index)
    }

    @MainActor
    func createTask() async -> Bool {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Title is required"
            return false
        }
        guard !selectedCategoryId.isEmpty else {
            errorMessage = "Please select a category"
            return false
        }
        guard !selectedAssigneeIds.isEmpty else {
            errorMessage = "Please assign at least one person"
            return false
        }

        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        let subtasks = subtaskTitles
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { SubtaskInput(title: $0.trimmingCharacters(in: .whitespacesAndNewlines)) }

        let input = CreateTaskInput(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description,
            categoryId: selectedCategoryId,
            priority: priority,
            assignmentType: selectedAssigneeIds.count > 1 ? .shared : .individual,
            assigneeIds: Array(selectedAssigneeIds),
            dueDate: dueDate,
            estimatedMinutes: Int(estimatedMinutes),
            isTemplate: false,
            templateId: nil,
            subtasks: subtasks,
            recurrence: nil
        )

        do {
            _ = try await createTaskUseCase.execute(input: input)
            return true
        } catch let error as APIError {
            errorMessage = error.userMessage
            return false
        } catch {
            errorMessage = "Failed to create task"
            return false
        }
    }
}
