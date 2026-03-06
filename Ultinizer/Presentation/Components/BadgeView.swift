import SwiftUI

enum BadgeColor: String {
    case magenta, green, blue, yellow, red, gray, orange

    func backgroundColor(colorScheme: ColorScheme) -> Color {
        switch self {
        case .magenta: return colorScheme == .dark ? AppColors.magenta900 : AppColors.magenta100
        case .green: return colorScheme == .dark ? AppColors.green900 : AppColors.green50
        case .blue: return colorScheme == .dark ? Color(hex: "1E3A5F") : Color(hex: "DBEAFE")
        case .yellow: return colorScheme == .dark ? AppColors.yellow900 : AppColors.yellow50
        case .red: return colorScheme == .dark ? AppColors.red900 : AppColors.red50
        case .gray: return colorScheme == .dark ? AppColors.gray700 : AppColors.gray100
        case .orange: return colorScheme == .dark ? Color(hex: "7C2D12") : Color(hex: "FFF7ED")
        }
    }

    func textColor(colorScheme: ColorScheme) -> Color {
        switch self {
        case .magenta: return colorScheme == .dark ? AppColors.magenta300 : AppColors.magenta700
        case .green: return colorScheme == .dark ? Color(hex: "6EE7B7") : AppColors.green700
        case .blue: return colorScheme == .dark ? Color(hex: "93C5FD") : Color(hex: "1D4ED8")
        case .yellow: return colorScheme == .dark ? AppColors.yellow300 : AppColors.yellow700
        case .red: return colorScheme == .dark ? Color(hex: "FCA5A5") : Color(hex: "DC2626")
        case .gray: return colorScheme == .dark ? AppColors.gray300 : AppColors.gray600
        case .orange: return colorScheme == .dark ? Color(hex: "FDBA74") : Color(hex: "C2410C")
        }
    }
}

enum BadgeSize {
    case sm, md

    var horizontalPadding: CGFloat {
        switch self {
        case .sm: return 8
        case .md: return 12
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .sm: return 2
        case .md: return 4
        }
    }
}

struct BadgeView: View {
    let label: String
    var color: BadgeColor = .magenta
    var size: BadgeSize = .md

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(label)
            .font(AppTypography.captionMedium)
            .foregroundColor(color.textColor(colorScheme: colorScheme))
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(color.backgroundColor(colorScheme: colorScheme))
            .clipShape(Capsule())
    }
}
