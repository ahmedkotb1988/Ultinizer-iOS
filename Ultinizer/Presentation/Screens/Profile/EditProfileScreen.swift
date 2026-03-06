import SwiftUI

struct EditProfileScreen: View {
    @State private var displayName = ""
    @State private var roleLabel = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    @Environment(\.dismiss) private var dismiss

    private let authManager: AuthManager
    private let updateProfileUseCase: UpdateProfileUseCaseProtocol

    init(authManager: AuthManager, updateProfileUseCase: UpdateProfileUseCaseProtocol) {
        self.authManager = authManager
        self.updateProfileUseCase = updateProfileUseCase
    }

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Edit Profile")
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
            dismiss()
        } catch let error as APIError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = "Failed to update profile"
        }
    }
}
