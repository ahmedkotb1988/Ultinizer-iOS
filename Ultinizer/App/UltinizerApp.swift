import SwiftUI
import UserNotifications

@main
struct UltinizerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var container = AppContainer()
    @State private var themeManager = ThemeManager()
    @State private var authManager: AuthManager?
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            Group {
                if let authManager {
                    RootView(
                        container: container,
                        authManager: authManager,
                        router: router,
                        themeManager: themeManager
                    )
                    .preferredColorScheme(themeManager.preferredColorScheme)
                    .environment(\.themeManager, themeManager)
                    .onChange(of: container.pushNotificationService.pendingDeepLinkTaskId) { _, taskId in
                        if let taskId {
                            router.selectedTab = .tasks
                            router.tasksPath = NavigationPath()
                            router.navigate(to: .taskDetail(id: taskId))
                            container.pushNotificationService.pendingDeepLinkTaskId = nil
                        }
                    }
                } else {
                    LoadingView(message: "")
                        .task {
                            // Wire up the AppDelegate to forward tokens to PushNotificationService
                            appDelegate.pushNotificationService = container.pushNotificationService

                            // Set UNUserNotificationCenter delegate
                            UNUserNotificationCenter.current().delegate = container.pushNotificationService

                            let manager = AuthManager(
                                loginUseCase: container.loginUseCase,
                                registerUseCase: container.registerUseCase,
                                logoutUseCase: container.logoutUseCase,
                                getMeUseCase: container.getMeUseCase,
                                householdRepository: container.householdRepository,
                                keychainService: container.keychainService,
                                userDefaultsService: container.userDefaultsService,
                                authRepository: container.authRepository,
                                pushNotificationService: container.pushNotificationService
                            )
                            await manager.bootstrap()
                            authManager = manager
                        }
                }
            }
        }
    }
}

// MARK: - App Delegate

final class AppDelegate: NSObject, UIApplicationDelegate {
    var pushNotificationService: PushNotificationService?

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            await pushNotificationService?.registerDeviceToken(deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[Push] Failed to register for remote notifications: \(error)")
    }
}

struct RootView: View {
    let container: AppContainer
    let authManager: AuthManager
    let router: AppRouter
    let themeManager: ThemeManager

    var body: some View {
        Group {
            if authManager.isLoading {
                LoadingView()
            } else if !authManager.isAuthenticated || authManager.awaitingBiometric {
                AuthFlow(
                    container: container,
                    authManager: authManager,
                    router: router
                )
            } else if authManager.household == nil {
                HouseholdSetupScreen(authManager: authManager) {
                    // Setup complete, household now set
                }
            } else {
                MainTabView(
                    container: container,
                    authManager: authManager,
                    router: router,
                    themeManager: themeManager
                )
            }
        }
    }
}

// MARK: - Auth Flow

struct AuthFlow: View {
    let container: AppContainer
    let authManager: AuthManager
    @Bindable var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.authPath) {
            LoginScreen(authManager: authManager, router: router)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .register:
                        RegisterScreen(authManager: authManager, router: router)
                    case .forgotPassword:
                        ForgotPasswordScreen(forgotPasswordUseCase: container.forgotPasswordUseCase, router: router)
                    case .householdSetup:
                        HouseholdSetupScreen(authManager: authManager) {
                            router.resetAll()
                        }
                    default:
                        EmptyView()
                    }
                }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    let container: AppContainer
    let authManager: AuthManager
    @Bindable var router: AppRouter
    let themeManager: ThemeManager

    var body: some View {
        TabView(selection: $router.selectedTab) {
            // Dashboard Tab
            NavigationStack(path: $router.dashboardPath) {
                DashboardScreen(container: container, authManager: authManager, router: router)
                    .navigationDestination(for: Route.self) { route in
                        routeDestination(route)
                    }
            }
            .tag(Tab.dashboard)
            .tabItem {
                Label(Tab.dashboard.title, systemImage: router.selectedTab == .dashboard ? Tab.dashboard.selectedIcon : Tab.dashboard.icon)
            }

            // Tasks Tab
            NavigationStack(path: $router.tasksPath) {
                TaskListScreen(container: container, router: router, authManager: authManager)
                    .navigationDestination(for: Route.self) { route in
                        routeDestination(route)
                    }
            }
            .tag(Tab.tasks)
            .tabItem {
                Label(Tab.tasks.title, systemImage: router.selectedTab == .tasks ? Tab.tasks.selectedIcon : Tab.tasks.icon)
            }

            // Calendar Tab
            NavigationStack(path: $router.calendarPath) {
                CalendarScreen(container: container, router: router)
                    .navigationDestination(for: Route.self) { route in
                        routeDestination(route)
                    }
            }
            .tag(Tab.calendar)
            .tabItem {
                Label(Tab.calendar.title, systemImage: router.selectedTab == .calendar ? Tab.calendar.selectedIcon : Tab.calendar.icon)
            }

            // Stats Tab
            NavigationStack(path: $router.statsPath) {
                StatisticsScreen(container: container)
                    .navigationDestination(for: Route.self) { route in
                        routeDestination(route)
                    }
            }
            .tag(Tab.stats)
            .tabItem {
                Label(Tab.stats.title, systemImage: router.selectedTab == .stats ? Tab.stats.selectedIcon : Tab.stats.icon)
            }

            // Profile Tab
            NavigationStack(path: $router.profilePath) {
                ProfileScreen(authManager: authManager, router: router, container: container, themeManager: themeManager)
                    .navigationDestination(for: Route.self) { route in
                        routeDestination(route)
                    }
            }
            .tag(Tab.profile)
            .tabItem {
                Label(Tab.profile.title, systemImage: router.selectedTab == .profile ? Tab.profile.selectedIcon : Tab.profile.icon)
            }
        }
        .tint(AppColors.magenta500)
        .sheet(isPresented: $router.showCreateTask) {
            CreateTaskScreen(container: container, authManager: authManager, router: router)
        }
    }

    @ViewBuilder
    private func routeDestination(_ route: Route) -> some View {
        switch route {
        case .taskDetail(let id):
            TaskDetailScreen(taskId: id, container: container, router: router, authManager: authManager)
        case .createTask:
            EmptyView() // Handled via sheet
        case .editTask(let id):
            CreateTaskScreen(container: container, authManager: authManager, router: router)
        case .editProfile, .changePassword, .notifications:
            EmptyView() // Presented as sheets from ProfileScreen
        case .statistics:
            StatisticsScreen(container: container)
        default:
            EmptyView()
        }
    }
}
