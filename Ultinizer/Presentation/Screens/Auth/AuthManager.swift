import Foundation
import Observation

@Observable
@MainActor
final class AuthManager {
    var user: User?
    var household: Household?
    var isLoading = true
    var isAuthenticated: Bool { user != nil }
    var awaitingBiometric = false
    var avatarVersion = 0

    private let loginUseCase: LoginUseCaseProtocol
    private let registerUseCase: RegisterUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let getMeUseCase: GetMeUseCaseProtocol
    private let householdRepository: HouseholdRepositoryProtocol
    private let keychainService: KeychainServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let authRepository: AuthRepositoryProtocol

    init(
        loginUseCase: LoginUseCaseProtocol,
        registerUseCase: RegisterUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        getMeUseCase: GetMeUseCaseProtocol,
        householdRepository: HouseholdRepositoryProtocol,
        keychainService: KeychainServiceProtocol,
        userDefaultsService: UserDefaultsServiceProtocol,
        authRepository: AuthRepositoryProtocol
    ) {
        self.loginUseCase = loginUseCase
        self.registerUseCase = registerUseCase
        self.logoutUseCase = logoutUseCase
        self.getMeUseCase = getMeUseCase
        self.householdRepository = householdRepository
        self.keychainService = keychainService
        self.userDefaultsService = userDefaultsService
        self.authRepository = authRepository
    }

    func bootstrap() async {
        isLoading = true
        defer { isLoading = false }

        do {
            guard let _ = try await keychainService.getAccessToken() else { return }

            let biometricEnabled = userDefaultsService.getBool(forKey: UserDefaultsService.Keys.biometricEnabled)

            if biometricEnabled {
                // Tokens exist and biometric is enabled — don't authenticate yet
                awaitingBiometric = true
                return
            }

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
                    let hh = try await householdRepository.getMyHousehold()
                    household = hh
                    cacheHousehold(hh)
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

    /// Complete login after successful biometric authentication
    func completeBiometricLogin() async {
        isLoading = true
        awaitingBiometric = false
        defer { isLoading = false }

        // Load cached user and household so the app is usable immediately
        if let data = userDefaultsService.getData(forKey: UserDefaultsService.Keys.cachedUser),
           let cached = try? JSONDecoder().decode(UserDTO.self, from: data) {
            user = UserMapper.map(cached)
        }
        if let hhData = userDefaultsService.getData(forKey: UserDefaultsService.Keys.cachedHousehold),
           let cachedHH = try? JSONDecoder().decode(HouseholdDTO.self, from: hhData) {
            household = HouseholdMapper.map(cachedHH)
        }

        // Try to fetch fresh data — don't wipe cached data on failure
        do {
            let freshUser = try await getMeUseCase.execute()
            user = freshUser
            cacheUser(freshUser)

            if freshUser.householdId != nil {
                if let hh = try? await householdRepository.getMyHousehold() {
                    household = hh
                    cacheHousehold(hh)
                }
            }
        } catch {
            // Network error — keep cached user/household if we have them
        }
    }

    func login(email: String, password: String) async throws -> LoginResult {
        let result = try await loginUseCase.execute(email: email, password: password)
        user = result.user
        household = result.household
        cacheUser(result.user)
        if let hh = result.household { cacheHousehold(hh) }
        return result
    }

    func register(input: RegisterInput) async throws -> LoginResult {
        let result = try await registerUseCase.execute(input: input)
        user = result.user
        household = result.household
        cacheUser(result.user)
        if let hh = result.household { cacheHousehold(hh) }
        return result
    }

    func logout() async {
        try? await logoutUseCase.execute()
        user = nil
        household = nil
        awaitingBiometric = false
        userDefaultsService.remove(forKey: UserDefaultsService.Keys.cachedUser)
        userDefaultsService.remove(forKey: UserDefaultsService.Keys.cachedHousehold)
        userDefaultsService.remove(forKey: UserDefaultsService.Keys.biometricEnabled)
    }

    func deleteAccount(password: String) async throws {
        try await authRepository.deleteAccount(password: password)
        user = nil
        household = nil
        userDefaultsService.remove(forKey: UserDefaultsService.Keys.cachedUser)
        userDefaultsService.remove(forKey: UserDefaultsService.Keys.cachedHousehold)
        userDefaultsService.remove(forKey: UserDefaultsService.Keys.biometricEnabled)
        userDefaultsService.remove(forKey: UserDefaultsService.Keys.onboardingCompleted)
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
                if let hh = try? await householdRepository.getMyHousehold() {
                    household = hh
                    cacheHousehold(hh)
                }
            }
        } catch {
            // Silent failure for refresh
        }
    }

    func setHousehold(_ hh: Household?) {
        household = hh
    }

    func bumpAvatarVersion() {
        avatarVersion += 1
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

    private func cacheHousehold(_ household: Household) {
        let dto = HouseholdDTO(
            id: household.id,
            name: household.name,
            inviteCode: household.inviteCode,
            createdAt: household.createdAt,
            updatedAt: household.updatedAt,
            members: household.members.map { UserDTO(
                id: $0.id,
                email: $0.email,
                displayName: $0.displayName,
                avatarUrl: $0.avatarUrl,
                roleLabel: $0.roleLabel,
                householdId: $0.householdId,
                createdAt: $0.createdAt,
                updatedAt: $0.updatedAt
            ) }
        )
        if let data = try? JSONEncoder().encode(dto) {
            userDefaultsService.setData(data, forKey: UserDefaultsService.Keys.cachedHousehold)
        }
    }
}
