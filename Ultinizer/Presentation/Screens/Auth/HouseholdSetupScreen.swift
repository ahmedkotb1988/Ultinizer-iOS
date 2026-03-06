import SwiftUI

struct HouseholdSetupScreen: View {
    enum Mode {
        case choose
        case create
        case join
    }

    @State private var mode: Mode = .choose
    @State private var name = ""
    @State private var inviteCode = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    @Environment(\.colorScheme) private var colorScheme

    private let authManager: AuthManager
    private let onComplete: () -> Void

    init(authManager: AuthManager, onComplete: @escaping () -> Void) {
        self.authManager = authManager
        self.onComplete = onComplete
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 60)

                // Header
                VStack(spacing: AppSpacing.xl) {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.xxl)
                            .fill(colorScheme == .dark ? AppColors.magenta900 : AppColors.magenta100)
                            .frame(width: 64, height: 64)
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.magenta500)
                    }

                    VStack(spacing: AppSpacing.md) {
                        Text("Set Up Your Household")
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Create a new household or join an existing one")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.gray500)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.bottom, AppSpacing.giant)

                // Error
                if !errorMessage.isEmpty {
                    ErrorBanner(message: errorMessage)
                        .padding(.bottom, AppSpacing.xl)
                }

                switch mode {
                case .choose:
                    chooseView
                case .create:
                    createView
                case .join:
                    joinView
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, AppSpacing.xxxl)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.backgroundPrimary)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Subviews

    private var chooseView: some View {
        VStack(spacing: AppSpacing.lg) {
            CardView(onTap: { mode = .create }) {
                HStack(spacing: AppSpacing.xl) {
                    ZStack {
                        Circle()
                            .fill(colorScheme == .dark ? AppColors.magenta950 : AppColors.magenta50)
                            .frame(width: 48, height: 48)
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.magenta500)
                    }
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Create Household")
                            .font(AppTypography.bodySemiBold)
                            .foregroundColor(AppColors.textPrimary)
                        Text("Start fresh and invite your partner")
                            .font(AppTypography.label)
                            .foregroundColor(AppColors.gray500)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.gray400)
                }
            }

            CardView(onTap: { mode = .join }) {
                HStack(spacing: AppSpacing.xl) {
                    ZStack {
                        Circle()
                            .fill(colorScheme == .dark ? AppColors.magenta950 : AppColors.magenta50)
                            .frame(width: 48, height: 48)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.magenta500)
                    }
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Join Household")
                            .font(AppTypography.bodySemiBold)
                            .foregroundColor(AppColors.textPrimary)
                        Text("Enter an invite code from your partner")
                            .font(AppTypography.label)
                            .foregroundColor(AppColors.gray500)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.gray400)
                }
            }
        }
    }

    private var createView: some View {
        VStack(spacing: 0) {
            TextInput(
                label: "Household Name",
                placeholder: "e.g. \"The Smiths\" or \"Our Home\"",
                text: $name
            )

            AppButton("Create", isLoading: isLoading) {
                Task { await handleCreate() }
            }

            AppButton("Back", variant: .ghost) {
                withAnimation { mode = .choose; errorMessage = "" }
            }
            .padding(.top, AppSpacing.md)
        }
    }

    private var joinView: some View {
        VStack(spacing: 0) {
            TextInput(
                label: "Invite Code",
                placeholder: "Enter the code from your partner",
                text: $inviteCode,
                autocapitalization: .characters
            )

            AppButton("Join", isLoading: isLoading) {
                Task { await handleJoin() }
            }

            AppButton("Back", variant: .ghost) {
                withAnimation { mode = .choose; errorMessage = "" }
            }
            .padding(.top, AppSpacing.md)
        }
    }

    // MARK: - Actions

    @MainActor
    private func handleCreate() async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        do {
            try await authManager.createHousehold(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
            onComplete()
        } catch let error as APIError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = "Failed to create household"
        }
    }

    @MainActor
    private func handleJoin() async {
        guard !inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        do {
            try await authManager.joinHousehold(inviteCode: inviteCode.trimmingCharacters(in: .whitespacesAndNewlines))
            onComplete()
        } catch let error as APIError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = "Failed to join household"
        }
    }
}
