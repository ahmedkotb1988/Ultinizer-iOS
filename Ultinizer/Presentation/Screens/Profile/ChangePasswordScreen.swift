import SwiftUI

struct ChangePasswordScreen: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var isLoading = false

    private let changePasswordUseCase: ChangePasswordUseCaseProtocol
    private let router: AppRouter

    init(changePasswordUseCase: ChangePasswordUseCaseProtocol, router: AppRouter) {
        self.changePasswordUseCase = changePasswordUseCase
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
                Text("Change Password")
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

                    if !successMessage.isEmpty {
                        SuccessBanner(message: successMessage)
                            .padding(.bottom, AppSpacing.xl)
                    }

                    TextInput(
                        label: "Current Password",
                        placeholder: "Enter current password",
                        text: $currentPassword,
                        isSecure: true,
                        textContentType: .password
                    )

                    TextInput(
                        label: "New Password",
                        placeholder: "At least 8 characters",
                        text: $newPassword,
                        isSecure: true,
                        textContentType: .newPassword
                    )

                    TextInput(
                        label: "Confirm New Password",
                        placeholder: "Re-enter new password",
                        text: $confirmPassword,
                        isSecure: true,
                        textContentType: .newPassword
                    )

                    AppButton("Change Password", isLoading: isLoading) {
                        Task { await changePassword() }
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
    }

    @MainActor
    private func changePassword() async {
        errorMessage = ""
        successMessage = ""

        guard !currentPassword.isEmpty else {
            errorMessage = "Current password is required"
            return
        }
        guard newPassword.count >= 8 else {
            errorMessage = "New password must be at least 8 characters"
            return
        }
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await changePasswordUseCase.execute(currentPassword: currentPassword, newPassword: newPassword)
            successMessage = "Password changed successfully"
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
        } catch let error as APIError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = "Failed to change password"
        }
    }
}
