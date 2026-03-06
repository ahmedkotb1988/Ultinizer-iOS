import Foundation

struct DashboardData: Equatable {
    let todayTasks: [HouseholdTask]
    let overdueTasks: [HouseholdTask]
    let upcomingTasks: [HouseholdTask]
    let recentActivity: [ActivityItem]
}

struct ActivityItem: Equatable, Hashable {
    let type: String
    let description: String
    let createdAt: Date
}

struct StatsOverview: Equatable {
    let completionRate: Double
    let totalTasks: Int
    let completedTasks: Int
    let byCategory: [CategoryStat]
    let byMember: [MemberStat]
    let streak: StreakInfo
    let weeklyTrend: [WeeklyTrendItem]
}

struct CategoryStat: Equatable, Hashable {
    let categoryId: String
    let categoryName: String
    let count: Int
}

struct MemberStat: Equatable, Hashable {
    let userId: String
    let displayName: String
    let total: Int
    let completed: Int

    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total) * 100
    }
}

struct StreakInfo: Equatable {
    let current: Int
    let longest: Int
}

struct WeeklyTrendItem: Equatable, Hashable {
    let date: String
    let completed: Int
    let created: Int
}
