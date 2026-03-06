import SwiftUI

struct ForgotPasswordScreen: View {
    @State private var viewModel: ForgotPasswordViewModel

    private let router: AppRouter

    init(forgotPasswordUseCase: ForgotPasswordUseCaseProtocol, router: AppRouter) {
        self.router = router
        _viewModel = State(initialValue: ForgotPasswordViewModel(forgotPasswordUseCase: forgotPasswordUseCase))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 80)

                // Header
                VStack(spacing: AppSpacing.xl) {
                    RoundedRectangle(cornerRadius: AppRadius.xxl)
                        .fill(AppColors.magenta500)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "envelope")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        )

                    VStack(spacing: AppSpacing.xs) {
                        Text("Forgot Password")
                            .font(AppTypography.hero)
                            .foregroundColor(AppColors.textPrimary)

                        Text(viewModel.isSent
                             ? "We sent you a password reset link"
                             : "Enter your email and we'll send you a reset link")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.gray500)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.xl)
                    }
                }
                .padding(.bottom, AppSpacing.giant)

                if viewModel.isSent {
                    SuccessBanner(message: "Check your email for a reset link. If you don't see it, check your spam folder.")
                        .padding(.bottom, AppSpacing.xl)
                } else {
                    // Error banner
                    if viewModel.hasError {
                        ErrorBanner(message: viewModel.errorMessage)
                            .padding(.bottom, AppSpacing.xl)
                    }

                    TextInput(
                        label: "Email",
                        placeholder: "you@example.com",
                        text: $viewModel.email,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .never
                    )

                    AppButton(
                        "Send Reset Link",
                        isLoading: viewModel.isLoading
                    ) {
                        Task { await viewModel.submit() }
                    }
                    .padding(.top, AppSpacing.md)
                }

                // Back to login
                Button(action: { router.popAuth() }) {
                    Text("Back to Sign In")
                        .font(AppTypography.labelSemiBold)
                        .foregroundColor(AppColors.magenta500)
                }
                .accessibilityLabel("Go back to sign in")
                .padding(.top, AppSpacing.xxxl)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, AppSpacing.xxxl)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.backgroundPrimary)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
