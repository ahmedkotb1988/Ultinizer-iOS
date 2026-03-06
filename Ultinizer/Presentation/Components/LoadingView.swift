import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            ProgressView()
                .tint(AppColors.magenta500)
                .scaleEffect(1.2)
            Text(message)
                .font(AppTypography.label)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.backgroundPrimary)
    }
}

struct SkeletonView: View {
    var height: CGFloat = 16
    var cornerRadius: CGFloat = AppRadius.md
    var isCircle: Bool = false

    @State private var opacity: Double = 0.3

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: isCircle ? height / 2 : cornerRadius)
            .fill(colorScheme == .dark ? AppColors.gray700 : AppColors.gray200)
            .frame(height: height)
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: true)) {
                    opacity = 0.7
                }
            }
    }
}

struct TaskSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SkeletonView(height: 16)
                .frame(width: 200)
            SkeletonView(height: 12)
                .frame(width: 150)
            HStack {
                SkeletonView(height: 24, cornerRadius: AppRadius.full)
                    .frame(width: 60)
                SkeletonView(height: 24, cornerRadius: AppRadius.full)
                    .frame(width: 80)
            }
        }
        .padding(AppSpacing.xl)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .stroke(AppColors.borderSecondary, lineWidth: 1)
        )
        .padding(.bottom, AppSpacing.md)
    }
}
