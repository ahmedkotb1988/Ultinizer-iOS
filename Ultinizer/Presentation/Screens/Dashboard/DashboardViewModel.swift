import Foundation
import Observation

@Observable
final class DashboardViewModel {
    var todayTasks: [HouseholdTask] = []
    var overdueTasks: [HouseholdTask] = []
    var upcomingTasks: [HouseholdTask] = []
    var isLoading = false
    var isRefreshing = false
    var errorMessage = ""

    private let getTasksUseCase: GetTasksUseCaseProtocol

    init(getTasksUseCase: GetTasksUseCaseProtocol) {
        self.getTasksUseCase = getTasksUseCase
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }

    @MainActor
    func loadDashboard() async {
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
    private func fetchTasks() async {
        do {
            let now = Date()
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: now)
            let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfToday)!

            // Overdue: dueDate < now AND status not done/verified
            let overdueResult = try await getTasksUseCase.execute(filters: TaskFilters(
                dueBefore: now,
                sortBy: .dueDate,
                sortOrder: .asc,
                limit: 10
            ))
            overdueTasks = overdueResult.tasks.filter { $0.status != TaskStatus.done && $0.status != TaskStatus.verified && $0.isOverdue }

            // Today: dueDate is today
            let todayResult = try await getTasksUseCase.execute(filters: TaskFilters(
                dueBefore: endOfToday,
                dueAfter: startOfToday,
                sortBy: .dueDate,
                sortOrder: .asc,
                limit: 20
            ))
            todayTasks = todayResult.tasks.filter { $0.status != TaskStatus.done && $0.status != TaskStatus.verified }

            // Upcoming: dueDate after today but within the week
            let upcomingResult = try await getTasksUseCase.execute(filters: TaskFilters(
                dueBefore: endOfWeek,
                dueAfter: endOfToday,
                sortBy: .dueDate,
                sortOrder: .asc,
                limit: 10
            ))
            upcomingTasks = upcomingResult.tasks.filter { $0.status != TaskStatus.done && $0.status != TaskStatus.verified }

            errorMessage = ""
        } catch {
            errorMessage = "Failed to load dashboard"
        }
    }
}
