import SwiftUI

struct LoginScreen: View {
    @State private var viewModel: LoginViewModel
    @Environment(\.colorScheme) private var colorScheme

    private let router: AppRouter
    private let authManager: AuthManager

    init(authManager: AuthManager, router: AppRouter) {
        self.authManager = authManager
        self.router = router
        _viewModel = State(initialValue: LoginViewModel(authManager: authManager))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 60)

                // Logo / Header
                VStack(spacing: AppSpacing.xl) {
                    RoundedRectangle(cornerRadius: AppRadius.xxl)
                        .fill(AppColors.magenta500)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "house.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        )

                    VStack(spacing: AppSpacing.xs) {
                        Text("Ultinizer")
                            .font(AppTypography.hero)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Household task management")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.gray500)
                    }
                }
                .padding(.bottom, AppSpacing.giant)

                // Error banner
                if viewModel.hasError {
                    ErrorBanner(message: viewModel.errorMessage)
                        .padding(.bottom, AppSpacing.xl)
                }

                // Form fields
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
                    placeholder: "Enter your password",
                    text: $viewModel.password,
                    isSecure: true,
                    textContentType: .password
                )

                // Forgot password link
                HStack {
                    Spacer()
                    Button(action: {
                        router.navigateAuth(to: .forgotPassword)
                    }) {
                        Text("Forgot password?")
                            .font(AppTypography.labelSemiBold)
                            .foregroundColor(AppColors.magenta500)
                    }
                }
                .padding(.top, -AppSpacing.xs)
                .padding(.bottom, AppSpacing.md)

                // Sign In button
                AppButton(
                    "Sign In",
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        if let result = await viewModel.login() {
                            if result.household != nil {
                                // Navigate to main app - handled by parent
                            } else {
                                router.navigateAuth(to: .householdSetup)
                            }
                        }
                    }
                }
                .padding(.top, AppSpacing.md)

                // Biometric button
                if let biometricType = viewModel.biometricType {
                    Button(action: {
                        // Biometric auth
                    }) {
                        VStack(spacing: AppSpacing.xs) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? AppColors.magenta950 : AppColors.magenta50)
                                    .frame(width: 48, height: 48)
                                Image(systemName: biometricType == "Face ID" ? "faceid" : "touchid")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppColors.magenta500)
                            }
                            Text("Use \(biometricType)")
                                .font(AppTypography.labelMedium)
                                .foregroundColor(AppColors.magenta500)
                        }
                    }
                    .padding(.top, AppSpacing.xl)
                }

                // Register link
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .font(AppTypography.label)
                        .foregroundColor(AppColors.gray500)
                    Button(action: {
                        router.navigateAuth(to: .register)
                    }) {
                        Text("Sign Up")
                            .font(AppTypography.labelSemiBold)
                            .foregroundColor(AppColors.magenta500)
                    }
                }
                .padding(.top, AppSpacing.xxxl)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, AppSpacing.xxxl)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.backgroundPrimary)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.checkBiometric()
        }
    }
}
