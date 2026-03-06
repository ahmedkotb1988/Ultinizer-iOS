import Foundation

final class AppContainer: @unchecked Sendable {
    // MARK: - Configuration

    let baseURL: URL

    // MARK: - Storage

    let keychainService: KeychainServiceProtocol
    let userDefaultsService: UserDefaultsServiceProtocol

    // MARK: - Network

    let authInterceptor: AuthInterceptor
    let apiClient: APIClientProtocol

    // MARK: - Repositories

    let authRepository: AuthRepositoryProtocol
    let householdRepository: HouseholdRepositoryProtocol
    let taskRepository: TaskRepositoryProtocol
    let categoryRepository: CategoryRepositoryProtocol
    let commentRepository: CommentRepositoryProtocol
    let subtaskRepository: SubtaskRepositoryProtocol
    let notificationRepository: NotificationRepositoryProtocol
    let statsRepository: StatsRepositoryProtocol
    let attachmentRepository: AttachmentRepositoryProtocol

    // MARK: - Use Cases: Auth

    let loginUseCase: LoginUseCaseProtocol
    let registerUseCase: RegisterUseCaseProtocol
    let logoutUseCase: LogoutUseCaseProtocol
    let getMeUseCase: GetMeUseCaseProtocol
    let forgotPasswordUseCase: ForgotPasswordUseCaseProtocol
    let changePasswordUseCase: ChangePasswordUseCaseProtocol
    let updateProfileUseCase: UpdateProfileUseCaseProtocol

    // MARK: - Use Cases: Tasks

    let getTasksUseCase: GetTasksUseCaseProtocol
    let getTaskUseCase: GetTaskUseCaseProtocol
    let createTaskUseCase: CreateTaskUseCaseProtocol
    let updateTaskUseCase: UpdateTaskUseCaseProtocol
    let deleteTaskUseCase: DeleteTaskUseCaseProtocol

    // MARK: - Use Cases: Comments

    let getCommentsUseCase: GetCommentsUseCaseProtocol
    let createCommentUseCase: CreateCommentUseCaseProtocol
    let deleteCommentUseCase: DeleteCommentUseCaseProtocol

    // MARK: - Use Cases: Notifications

    let getNotificationsUseCase: GetNotificationsUseCaseProtocol

    init() {
        // Configuration
        let baseURLString = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "https://ultinizer.cloud"
        self.baseURL = URL(string: baseURLString)!

        // Storage
        let keychain = KeychainService()
        self.keychainService = keychain
        self.userDefaultsService = UserDefaultsService()

        // Network
        let interceptor = AuthInterceptor(keychainService: keychain, baseURL: baseURL)
        self.authInterceptor = interceptor
        self.apiClient = APIClient(baseURL: baseURL, authInterceptor: interceptor)

        // Repositories
        let authRepo = AuthRepository(apiClient: apiClient, keychainService: keychain)
        self.authRepository = authRepo
        let householdRepo = HouseholdRepository(apiClient: apiClient)
        self.householdRepository = householdRepo
        self.taskRepository = TaskRepository(apiClient: apiClient)
        let categoryRepo = CategoryRepository(apiClient: apiClient)
        self.categoryRepository = categoryRepo
        let commentRepo = CommentRepository(apiClient: apiClient)
        self.commentRepository = commentRepo
        let subtaskRepo = SubtaskRepository(apiClient: apiClient)
        self.subtaskRepository = subtaskRepo
        self.notificationRepository = NotificationRepository(apiClient: apiClient)
        self.statsRepository = StatsRepository(apiClient: apiClient)
        self.attachmentRepository = AttachmentRepository(apiClient: apiClient)

        // Use Cases: Auth
        self.loginUseCase = LoginUseCase(authRepository: authRepo)
        self.registerUseCase = RegisterUseCase(authRepository: authRepo)
        self.logoutUseCase = LogoutUseCase(authRepository: authRepo)
        self.getMeUseCase = GetMeUseCase(authRepository: authRepo)
        self.forgotPasswordUseCase = ForgotPasswordUseCase(authRepository: authRepo)
        self.changePasswordUseCase = ChangePasswordUseCase(authRepository: authRepo)
        self.updateProfileUseCase = UpdateProfileUseCase(authRepository: authRepo)

        // Use Cases: Tasks
        self.getTasksUseCase = GetTasksUseCase(taskRepository: taskRepository)
        self.getTaskUseCase = GetTaskUseCase(taskRepository: taskRepository)
        self.createTaskUseCase = CreateTaskUseCase(taskRepository: taskRepository)
        self.updateTaskUseCase = UpdateTaskUseCase(taskRepository: taskRepository)
        self.deleteTaskUseCase = DeleteTaskUseCase(taskRepository: taskRepository)

        // Use Cases: Comments
        self.getCommentsUseCase = GetCommentsUseCase(commentRepository: commentRepo)
        self.createCommentUseCase = CreateCommentUseCase(commentRepository: commentRepo)
        self.deleteCommentUseCase = DeleteCommentUseCase(commentRepository: commentRepo)

        // Use Cases: Notifications
        self.getNotificationsUseCase = GetNotificationsUseCase(notificationRepository: notificationRepository)
    }
}
