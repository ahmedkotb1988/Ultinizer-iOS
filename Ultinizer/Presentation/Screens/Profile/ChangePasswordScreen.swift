import SwiftUI

struct ChangePasswordScreen: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var isLoading = false

    @Environment(\.dismiss) private var dismiss

    private let changePasswordUseCase: ChangePasswordUseCaseProtocol

    init(changePasswordUseCase: ChangePasswordUseCaseProtocol) {
        self.changePasswordUseCase = changePasswordUseCase
    }

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.gray400)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .background(AppColors.backgroundSecondary)
        }
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
