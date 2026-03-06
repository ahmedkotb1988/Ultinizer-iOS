import Foundation
import Observation

@Observable
final class AuthManager {
    var user: User?
    var household: Household?
    var isLoading = true
    var isAuthenticated: Bool { user != nil }

    private let loginUseCase: LoginUseCaseProtocol
    private let registerUseCase: RegisterUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let getMeUseCase: GetMeUseCaseProtocol
    private let householdRepository: HouseholdRepositoryProtocol
    private let keychainService: KeychainServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol

    init(
        loginUseCase: LoginUseCaseProtocol,
        registerUseCase: RegisterUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        getMeUseCase: GetMeUseCaseProtocol,
        householdRepository: HouseholdRepositoryProtocol,
        keychainService: KeychainServiceProtocol,
        userDefaultsService: UserDefaultsServiceProtocol
    ) {
        self.loginUseCase = loginUseCase
        self.registerUseCase = registerUseCase
        self.logoutUseCase = logoutUseCase
        self.getMeUseCase = getMeUseCase
        self.householdRepository = householdRepository
        self.keychainService = keychainService
        self.userDefaultsService = userDefaultsService
    }

    func bootstrap() async {
        isLoading = true
        defer { isLoading = false }

        do {
            guard let _ = try await keychainService.getAccessToken() else { return }

            // Try to load cached user first
            if let data = userDefaultsService.getData(forKey: UserDefaultsService.Keys.cachedUser),
               let cached = try? JSONDecoder().decode(UserDTO.self, from: data) {
                user = UserMapper.map(cached)
            }

            // Fetch fresh data
            let freshUser = try await getMeUseCase.execute()
            user = freshUser

            // Cache user
            cacheUser(freshUser)

            // Try to fetch household
            if freshUser.householdId != nil {
                do {
                    household = try await householdRepository.getMyHousehold()
                } catch {
                    // No household or error - that's ok
                }
            }
        } catch {
            // Token invalid or network error
            user = nil
            household = nil
        }
    }

    func login(email: String, password: String) async throws -> LoginResult {
        let result = try await loginUseCase.execute(email: email, password: password)
        user = result.user
        household = result.household
        cacheUser(result.user)
        return result
    }

    func register(input: RegisterInput) async throws -> LoginResult {
        let result = try await registerUseCase.execute(input: input)
        user = result.user
        household = result.household
        cacheUser(result.user)
        return result
    }

    func logout() async {
        try? await logoutUseCase.execute()
        user = nil
        household = nil
        userDefaultsService.remove(forKey: UserDefaultsService.Keys.cachedUser)
    }

    func createHousehold(name: String) async throws {
        let hh = try await householdRepository.createHousehold(name: name)
        household = hh
    }

    func joinHousehold(inviteCode: String) async throws {
        let hh = try await householdRepository.joinHousehold(inviteCode: inviteCode)
        household = hh
    }

    func refreshUser() async {
        do {
            let freshUser = try await getMeUseCase.execute()
            user = freshUser
            cacheUser(freshUser)
            if freshUser.householdId != nil {
                household = try? await householdRepository.getMyHousehold()
            }
        } catch {
            // Silent failure for refresh
        }
    }

    func setHousehold(_ hh: Household?) {
        household = hh
    }

    private func cacheUser(_ user: User) {
        let dto = UserDTO(
            id: user.id,
            email: user.email,
            displayName: user.displayName,
            avatarUrl: user.avatarUrl,
            roleLabel: user.roleLabel,
            householdId: user.householdId,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt
        )
        if let data = try? JSONEncoder().encode(dto) {
            userDefaultsService.setData(data, forKey: UserDefaultsService.Keys.cachedUser)
        }
    }
}
