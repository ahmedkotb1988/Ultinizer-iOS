import SwiftUI

struct EditProfileScreen: View {
    @State private var displayName = ""
    @State private var roleLabel = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    private let authManager: AuthManager
    private let updateProfileUseCase: UpdateProfileUseCaseProtocol
    private let router: AppRouter

    init(authManager: AuthManager, updateProfileUseCase: UpdateProfileUseCaseProtocol, router: AppRouter) {
        self.authManager = authManager
        self.updateProfileUseCase = updateProfileUseCase
        self.router = router
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { router.pop() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.magenta500)
                }
                Spacer()
                Text("Edit Profile")
                    .font(AppTypography.heading)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Color.clear.frame(width: 60)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.lg)
            .overlay(Divider().foregroundColor(AppColors.borderPrimary), alignment: .bottom)

            ScrollView {
                VStack(spacing: 0) {
                    if !errorMessage.isEmpty {
                        ErrorBanner(message: errorMessage)
                            .padding(.bottom, AppSpacing.xl)
                    }

                    TextInput(
                        label: "Display Name",
                        placeholder: "Your name",
                        text: $displayName,
                        autocapitalization: .words
                    )

                    TextInput(
                        label: "Role Label",
                        placeholder: "e.g. Husband, Wife",
                        text: $roleLabel
                    )

                    AppButton("Save Changes", isLoading: isLoading) {
                        Task { await save() }
                    }
                    .padding(.top, AppSpacing.md)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(AppColors.backgroundSecondary)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            displayName = authManager.user?.displayName ?? ""
            roleLabel = authManager.user?.roleLabel ?? ""
        }
    }

    @MainActor
    private func save() async {
        errorMessage = ""
        guard !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Display name is required"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await updateProfileUseCase.execute(
                displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
                roleLabel: roleLabel.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            await authManager.refreshUser()
            router.pop()
        } catch let error as APIError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = "Failed to update profile"
        }
    }
}
