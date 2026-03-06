import Foundation

enum Route: Hashable {
    // Auth
    case login
    case register
    case forgotPassword
    case resetPassword(token: String)
    case householdSetup

    // Main
    case dashboard
    case taskList
    case taskDetail(id: String)
    case createTask
    case editTask(id: String)
    case calendar
    case kanbanBoard
    case notifications
    case profile
    case editProfile
    case changePassword
    case settings
    case statistics
}

enum Tab: String, CaseIterable {
    case dashboard
    case tasks
    case calendar
    case stats
    case profile

    var title: String {
        switch self {
        case .dashboard: return "Home"
        case .tasks: return "Tasks"
        case .calendar: return "Calendar"
        case .stats: return "Stats"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "house"
        case .tasks: return "checklist"
        case .calendar: return "calendar"
        case .stats: return "chart.bar"
        case .profile: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .tasks: return "checklist"
        case .calendar: return "calendar"
        case .stats: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }
}
