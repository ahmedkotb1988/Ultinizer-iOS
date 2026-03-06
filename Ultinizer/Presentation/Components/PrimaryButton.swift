import SwiftUI

enum ButtonVariant {
    case primary
    case secondary
    case outline
    case ghost
    case danger

    func backgroundColor(isPressed: Bool, colorScheme: ColorScheme) -> Color {
        switch self {
        case .primary:
            return isPressed ? AppColors.magenta600 : AppColors.magenta500
        case .secondary:
            return isPressed
                ? (colorScheme == .dark ? AppColors.gray600 : AppColors.gray300)
                : (colorScheme == .dark ? AppColors.gray700 : AppColors.gray200)
        case .outline:
            return isPressed
                ? (colorScheme == .dark ? AppColors.magenta950 : AppColors.magenta50)
                : .clear
        case .ghost:
            return isPressed
                ? (colorScheme == .dark ? AppColors.gray800 : AppColors.gray100)
                : .clear
        case .danger:
            return isPressed ? Color(hex: "DC2626") : AppColors.red500
        }
    }

    func foregroundColor(colorScheme: ColorScheme) -> Color {
        switch self {
        case .primary, .danger:
            return .white
        case .secondary:
            return colorScheme == .dark ? AppColors.gray100 : AppColors.gray900
        case .outline:
            return AppColors.magenta500
        case .ghost:
            return colorScheme == .dark ? AppColors.gray300 : AppColors.gray700
        }
    }

    func borderColor(colorScheme: ColorScheme) -> Color? {
        switch self {
        case .outline:
            return AppColors.magenta500
        default:
            return nil
        }
    }
}

enum ButtonSize {
    case sm, md, lg

    var horizontalPadding: CGFloat {
        switch self {
        case .sm: return 12
        case .md: return 20
        case .lg: return 24
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .sm: return 6
        case .md: return 12
        case .lg: return 16
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .sm: return AppRadius.md
        case .md: return AppRadius.lg
        case .lg: return AppRadius.xl
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .sm: return AppTypography.sizeSM
        case .md: return AppTypography.sizeBase
        case .lg: return AppTypography.sizeLG
        }
    }
}

struct AppButton: View {
    let title: String
    let variant: ButtonVariant
    let size: ButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let icon: String?
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    init(
        _ title: String,
        variant: ButtonVariant = .primary,
        size: ButtonSize = .md,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(variant.foregroundColor(colorScheme: colorScheme))
                        .scaleEffect(0.8)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: size.fontSize - 2))
                    }
                    Text(title)
                        .font(AppTypography.semiBold(size.fontSize))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .foregroundColor(variant.foregroundColor(colorScheme: colorScheme))
            .background(variant.backgroundColor(isPressed: false, colorScheme: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(variant.borderColor(colorScheme: colorScheme) ?? .clear, lineWidth: variant == .outline ? 1 : 0)
            )
        }
        .disabled(isLoading || isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}
