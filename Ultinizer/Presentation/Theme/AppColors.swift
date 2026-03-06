import SwiftUI

struct AppColors {
    // MARK: - Primary: Magenta
    static let magenta50 = Color(hex: "FDE8F3")
    static let magenta100 = Color(hex: "FBC5E2")
    static let magenta200 = Color(hex: "F78EC5")
    static let magenta300 = Color(hex: "F357A8")
    static let magenta400 = Color(hex: "EE3294")
    static let magenta500 = Color(hex: "E91E8C")
    static let magenta600 = Color(hex: "D11A7E")
    static let magenta700 = Color(hex: "B0156A")
    static let magenta800 = Color(hex: "8F1056")
    static let magenta900 = Color(hex: "6E0C42")
    static let magenta950 = Color(hex: "4D0830")

    // MARK: - Neutral: Gray
    static let gray50 = Color(hex: "F9FAFB")
    static let gray100 = Color(hex: "F3F4F6")
    static let gray200 = Color(hex: "E5E7EB")
    static let gray300 = Color(hex: "D1D5DB")
    static let gray400 = Color(hex: "9CA3AF")
    static let gray500 = Color(hex: "6B7280")
    static let gray600 = Color(hex: "4B5563")
    static let gray700 = Color(hex: "374151")
    static let gray800 = Color(hex: "1F2937")
    static let gray900 = Color(hex: "111827")
    static let gray950 = Color(hex: "030712")

    // MARK: - Status Colors
    static let green500 = Color(hex: "10B981")
    static let yellow500 = Color(hex: "F59E0B")
    static let orange500 = Color(hex: "F97316")
    static let red500 = Color(hex: "EF4444")
    static let blue500 = Color(hex: "3B82F6")

    // Additional status shades for backgrounds
    static let red50 = Color(hex: "FEF2F2")
    static let red200 = Color(hex: "FECACA")
    static let red600 = Color(hex: "DC2626")
    static let red800 = Color(hex: "991B1B")
    static let red900 = Color(hex: "7F1D1D")

    static let green50 = Color(hex: "ECFDF5")
    static let green200 = Color(hex: "A7F3D0")
    static let green700 = Color(hex: "047857")
    static let green800 = Color(hex: "065F46")
    static let green900 = Color(hex: "064E3B")

    static let yellow50 = Color(hex: "FFFBEB")
    static let yellow200 = Color(hex: "FDE68A")
    static let yellow300 = Color(hex: "FCD34D")
    static let yellow700 = Color(hex: "B45309")
    static let yellow800 = Color(hex: "92400E")
    static let yellow900 = Color(hex: "78350F")

    // MARK: - Semantic Colors (Light/Dark adaptive)

    static let backgroundPrimary = Color.adaptive(light: "FFFFFF", dark: "030712")
    static let backgroundSecondary = Color.adaptive(light: "F9FAFB", dark: "111827")
    static let backgroundTertiary = Color.adaptive(light: "F3F4F6", dark: "1F2937")

    static let surfacePrimary = Color.adaptive(light: "FFFFFF", dark: "111827")
    static let surfaceElevated = Color.adaptive(light: "FFFFFF", dark: "1F2937")

    static let textPrimary = Color.adaptive(light: "111827", dark: "F9FAFB")
    static let textSecondary = Color.adaptive(light: "4B5563", dark: "9CA3AF")
    static let textTertiary = Color.adaptive(light: "9CA3AF", dark: "4B5563")
    static let textInverse = Color.adaptive(light: "FFFFFF", dark: "111827")

    static let borderPrimary = Color.adaptive(light: "E5E7EB", dark: "374151")
    static let borderSecondary = Color.adaptive(light: "F3F4F6", dark: "1F2937")
    static let borderFocus = Color.adaptive(light: "E91E8C", dark: "EE3294")

    static let accentPrimary = Color.adaptive(light: "E91E8C", dark: "EE3294")
    static let accentPressed = Color.adaptive(light: "D11A7E", dark: "F357A8")
}

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static func adaptive(light: String, dark: String) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(Color(hex: dark)) : UIColor(Color(hex: light))
        })
    }
}
