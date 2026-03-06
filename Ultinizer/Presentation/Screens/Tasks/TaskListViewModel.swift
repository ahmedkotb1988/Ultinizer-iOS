import Foundation
import Observation

@Observable
final class TaskListViewModel {
    var tasks: [HouseholdTask] = []
    var isLoading = false
    var isRefreshing = false
    var errorMessage = ""

    // Filters
    var searchText = ""
    var selectedStatus: TaskStatus?
    var selectedPriority: TaskPriority?
    var selectedCategoryId: String?
    var selectedAssigneeId: String?

    var categories: [TaskCategory] = []

    private let getTasksUseCase: GetTasksUseCaseProtocol
    private let updateTaskUseCase: UpdateTaskUseCaseProtocol
    private let categoryRepository: CategoryRepositoryProtocol

    init(
        getTasksUseCase: GetTasksUseCaseProtocol,
        updateTaskUseCase: UpdateTaskUseCaseProtocol,
        categoryRepository: CategoryRepositoryProtocol
    ) {
        self.getTasksUseCase = getTasksUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.categoryRepository = categoryRepository
    }

    var currentFilters: TaskFilters {
        TaskFilters(
            status: selectedStatus,
            priority: selectedPriority,
            categoryId: selectedCategoryId,
            assigneeId: selectedAssigneeId,
            search: searchText.isEmpty ? nil : searchText,
            sortBy: .createdAt,
            sortOrder: .desc,
            limit: 50
        )
    }

    var hasActiveFilters: Bool {
        selectedStatus != nil || selectedPriority != nil ||
        selectedCategoryId != nil || selectedAssigneeId != nil ||
        !searchText.isEmpty
    }

    @MainActor
    func loadTasks() async {
        isLoading = true
        defer { isLoading = false }
        await fetchTasks()
    }

    @MainActor
    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        await fetchTasks()
    }

    @MainActor
    func loadCategories() async {
        do {
            categories = try await categoryRepository.getCategories()
        } catch {
            // Silent failure
        }
    }

    @MainActor
    func changeTaskStatus(taskId: String, status: TaskStatus) async {
        do {
            let input = UpdateTaskInput(status: status)
            _ = try await updateTaskUseCase.execute(id: taskId, input: input)
            await fetchTasks()
        } catch {
            errorMessage = "Failed to update task status"
        }
    }

    func clearFilters() {
        selectedStatus = nil
        selectedPriority = nil
        selectedCategoryId = nil
        selectedAssigneeId = nil
        searchText = ""
    }

    @MainActor
    private func fetchTasks() async {
        do {
            let result = try await getTasksUseCase.execute(filters: currentFilters)
            tasks = result.tasks
            errorMessage = ""
        } catch {
            errorMessage = "Failed to load tasks"
        }
    }
}
