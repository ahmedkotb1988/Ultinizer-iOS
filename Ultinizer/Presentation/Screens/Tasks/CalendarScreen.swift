import SwiftUI

struct CalendarScreen: View {
    @State private var selectedDate = Date()
    @State private var tasks: [HouseholdTask] = []
    @State private var isLoading = false
    @State private var currentMonth = Date()

    private let container: AppContainer
    private let router: AppRouter

    @Environment(\.colorScheme) private var colorScheme

    init(container: AppContainer, router: AppRouter) {
        self.container = container
        self.router = router
    }

    var tasksForSelectedDate: [HouseholdTask] {
        let calendar = Calendar.current
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: selectedDate)
        }
    }

    var taskDates: Set<String> {
        var dates = Set<String>()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        for task in tasks {
            if let dueDate = task.dueDate {
                dates.insert(formatter.string(from: dueDate))
            }
        }
        return dates
    }

    var body: some View {
        VStack(spacing: 0) {
            // Month calendar header
            calendarView

            Divider().foregroundColor(AppColors.borderPrimary)

            // Selected date header
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(AppTypography.bodySemiBold)
                    .foregroundColor(AppColors.textPrimary)
                Text("\(tasksForSelectedDate.count) task\(tasksForSelectedDate.count != 1 ? "s" : "")")
                    .font(AppTypography.label)
                    .foregroundColor(AppColors.gray500)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.lg)

            // Tasks for selected date
            if isLoading {
                VStack {
                    TaskSkeletonView()
                    TaskSkeletonView()
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                Spacer()
            } else if tasksForSelectedDate.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "No tasks on this day",
                    description: "Tasks with due dates will appear here"
                )
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(tasksForSelectedDate) { task in
                            TaskCard(task: task, onTap: {
                                router.navigate(to: .taskDetail(id: task.id))
                            })
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .background(AppColors.backgroundSecondary)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadTasks()
        }
    }

    private var calendarView: some View {
        VStack(spacing: AppSpacing.md) {
            // Month navigation
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.magenta500)
                }
                Spacer()
                Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                    .font(AppTypography.bodySemiBold)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.magenta500)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.xl)

            // Weekday headers
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(AppTypography.captionMedium)
                        .foregroundColor(AppColors.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, AppSpacing.md)

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: AppSpacing.xs) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date {
                        dayCell(date: date)
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
        }
        .background(AppColors.backgroundPrimary)
    }

    private func dayCell(date: Date) -> some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        let hasTasks = taskDates.contains(dateString)

        return Button(action: { selectedDate = date }) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(AppTypography.label)
                    .foregroundColor(
                        isSelected ? .white
                        : isToday ? AppColors.magenta500
                        : AppColors.textPrimary
                    )
                    .frame(width: 32, height: 32)
                    .background(
                        isSelected ? AppColors.magenta500
                        : .clear
                    )
                    .clipShape(Circle())

                if hasTasks {
                    Circle()
                        .fill(isSelected ? .white : AppColors.magenta500)
                        .frame(width: 4, height: 4)
                } else {
                    Color.clear.frame(width: 4, height: 4)
                }
            }
        }
        .frame(height: 40)
    }

    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let weekday = calendar.component(.weekday, from: firstDay)

        var days: [Date?] = Array(repeating: nil, count: weekday - 1)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }

        return days
    }

    private func changeMonth(by months: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: months, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func loadTasks() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await container.getTasksUseCase.execute(filters: TaskFilters(limit: 100))
            tasks = result.tasks
        } catch {
            // Silent
        }
    }
}
