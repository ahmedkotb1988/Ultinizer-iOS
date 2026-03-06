import SwiftUI
import Observation

@Observable
final class AppRouter {
    var authPath = NavigationPath()
    var dashboardPath = NavigationPath()
    var tasksPath = NavigationPath()
    var calendarPath = NavigationPath()
    var statsPath = NavigationPath()
    var profilePath = NavigationPath()

    var selectedTab: Tab = .dashboard
    var showCreateTask = false

    // MARK: - Auth Navigation

    func navigateAuth(to route: Route) {
        authPath.append(route)
    }

    func popAuth() {
        if !authPath.isEmpty {
            authPath.removeLast()
        }
    }

    // MARK: - Tab Navigation

    func navigate(to route: Route) {
        switch selectedTab {
        case .dashboard: dashboardPath.append(route)
        case .tasks: tasksPath.append(route)
        case .calendar: calendarPath.append(route)
        case .stats: statsPath.append(route)
        case .profile: profilePath.append(route)
        }
    }

    func pop() {
        switch selectedTab {
        case .dashboard:
            if !dashboardPath.isEmpty { dashboardPath.removeLast() }
        case .tasks:
            if !tasksPath.isEmpty { tasksPath.removeLast() }
        case .calendar:
            if !calendarPath.isEmpty { calendarPath.removeLast() }
        case .stats:
            if !statsPath.isEmpty { statsPath.removeLast() }
        case .profile:
            if !profilePath.isEmpty { profilePath.removeLast() }
        }
    }

    func popToRoot() {
        switch selectedTab {
        case .dashboard: dashboardPath = NavigationPath()
        case .tasks: tasksPath = NavigationPath()
        case .calendar: calendarPath = NavigationPath()
        case .stats: statsPath = NavigationPath()
        case .profile: profilePath = NavigationPath()
        }
    }

    func resetAll() {
        authPath = NavigationPath()
        dashboardPath = NavigationPath()
        tasksPath = NavigationPath()
        calendarPath = NavigationPath()
        statsPath = NavigationPath()
        profilePath = NavigationPath()
        selectedTab = .dashboard
    }
}
