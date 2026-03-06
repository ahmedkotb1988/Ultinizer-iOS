import SwiftUI

struct RegisterScreen: View {
    @State private var viewModel: RegisterViewModel
    @Environment(\.colorScheme) private var colorScheme

    private let router: AppRouter

    init(authManager: AuthManager, router: AppRouter) {
        self.router = router
        _viewModel = State(initialValue: RegisterViewModel(authManager: authManager))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Button(action: { router.popAuth() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.magenta500)
                    }
                    .padding(.bottom, AppSpacing.xl)

                    Text("Create Account")
                        .font(AppTypography.hero)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Start managing your household tasks")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.gray500)
                }
                .padding(.bottom, AppSpacing.huge)

                // Error banner
                if viewModel.hasError {
                    ErrorBanner(message: viewModel.errorMessage)
                        .padding(.bottom, AppSpacing.xl)
                }

                // Form
                TextInput(
                    label: "Display Name",
                    placeholder: "John",
                    text: $viewModel.displayName,
                    textContentType: .name,
                    autocapitalization: .words
                )

                TextInput(
                    label: "Email",
                    placeholder: "you@example.com",
                    text: $viewModel.email,
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress,
                    autocapitalization: .never
                )

                TextInput(
                    label: "Password",
                    placeholder: "At least 8 characters",
                    text: $viewModel.password,
                    isSecure: true,
                    textContentType: .newPassword
                )

                TextInput(
                    label: "Role Label (optional)",
                    placeholder: "e.g. \"Husband\", \"Wife\", \"Partner\"",
                    text: $viewModel.roleLabel
                )

                AppButton(
                    "Create Account",
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        let success = await viewModel.register()
                        if success {
                            router.navigateAuth(to: .householdSetup)
                        }
                    }
                }
                .padding(.top, AppSpacing.md)

                // Sign in link
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(AppTypography.label)
                        .foregroundColor(AppColors.gray500)
                    Button(action: { router.popAuth() }) {
                        Text("Sign In")
                            .font(AppTypography.labelSemiBold)
                            .foregroundColor(AppColors.magenta500)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, AppSpacing.xxxl)
            }
            .padding(.horizontal, AppSpacing.xxxl)
            .padding(.top, AppSpacing.xl)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.backgroundPrimary)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
