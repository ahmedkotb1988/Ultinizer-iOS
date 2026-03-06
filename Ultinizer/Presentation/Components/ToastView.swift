import SwiftUI

enum ToastType {
    case success
    case error
    case info

    var color: Color {
        switch self {
        case .success: return AppColors.green500
        case .error: return AppColors.red500
        case .info: return AppColors.blue500
        }
    }

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

struct ToastView: View {
    let message: String
    let type: ToastType

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
            Text(message)
                .font(AppTypography.label)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(2)
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.vertical, AppSpacing.lg)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, AppSpacing.xxl)
    }
}

struct ErrorBanner: View {
    let message: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.circle")
                .foregroundColor(colorScheme == .dark ? AppColors.red500 : Color(hex: "DC2626"))
                .font(.system(size: 16))
            Text(message)
                .font(AppTypography.label)
                .foregroundColor(colorScheme == .dark ? Color(hex: "FCA5A5") : Color(hex: "DC2626"))
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? AppColors.red500.opacity(0.2) : AppColors.red50)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(colorScheme == .dark ? AppColors.red800 : AppColors.red200, lineWidth: 1)
        )
    }
}

struct SuccessBanner: View {
    let message: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "checkmark.circle")
                .foregroundColor(AppColors.green500)
                .font(.system(size: 16))
            Text(message)
                .font(AppTypography.label)
                .foregroundColor(colorScheme == .dark ? Color(hex: "6EE7B7") : AppColors.green700)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? AppColors.green500.opacity(0.2) : AppColors.green50)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(colorScheme == .dark ? AppColors.green800 : AppColors.green200, lineWidth: 1)
        )
    }
}
