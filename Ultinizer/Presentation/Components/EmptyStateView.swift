import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var actionTitle: String?
    var onAction: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? AppColors.magenta950 : AppColors.magenta50)
                    .frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.magenta500)
            }

            VStack(spacing: AppSpacing.md) {
                Text(title)
                    .font(AppTypography.heading)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(AppTypography.label)
                    .foregroundColor(AppColors.textTertiary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let onAction {
                AppButton(actionTitle, variant: .primary, size: .md, action: onAction)
                    .frame(width: 200)
            }
        }
        .padding(AppSpacing.huge)
    }
}
