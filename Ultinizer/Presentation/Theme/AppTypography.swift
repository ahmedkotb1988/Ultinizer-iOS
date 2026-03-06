import SwiftUI

struct AppTypography {
    // Using Inter font - must be included in the app bundle
    // Fallback to system font if Inter is not available

    static let fontNameRegular = "Inter-Regular"
    static let fontNameMedium = "Inter-Medium"
    static let fontNameSemiBold = "Inter-SemiBold"
    static let fontNameBold = "Inter-Bold"

    // MARK: - Font Sizes (matching design spec)

    static let sizeXS: CGFloat = 12
    static let sizeSM: CGFloat = 14
    static let sizeBase: CGFloat = 16
    static let sizeLG: CGFloat = 18
    static let sizeXL: CGFloat = 20
    static let size2XL: CGFloat = 24
    static let size3XL: CGFloat = 30

    static let tabLabelSize: CGFloat = 11

    // MARK: - Fonts

    static func regular(_ size: CGFloat) -> Font {
        .custom(fontNameRegular, size: size)
    }

    static func medium(_ size: CGFloat) -> Font {
        .custom(fontNameMedium, size: size)
    }

    static func semiBold(_ size: CGFloat) -> Font {
        .custom(fontNameSemiBold, size: size)
    }

    static func bold(_ size: CGFloat) -> Font {
        .custom(fontNameBold, size: size)
    }

    // MARK: - Semantic Text Styles

    static let caption = regular(sizeXS)
    static let captionMedium = medium(sizeXS)
    static let label = regular(sizeSM)
    static let labelMedium = medium(sizeSM)
    static let labelSemiBold = semiBold(sizeSM)
    static let body = regular(sizeBase)
    static let bodyMedium = medium(sizeBase)
    static let bodySemiBold = semiBold(sizeBase)
    static let heading = semiBold(sizeLG)
    static let title = semiBold(sizeXL)
    static let largeTitle = bold(size2XL)
    static let hero = bold(size3XL)
    static let tabLabel = medium(tabLabelSize)
}

// MARK: - UIFont extension for Inter

extension UIFont {
    static func interRegular(_ size: CGFloat) -> UIFont {
        UIFont(name: AppTypography.fontNameRegular, size: size) ?? .systemFont(ofSize: size, weight: .regular)
    }

    static func interMedium(_ size: CGFloat) -> UIFont {
        UIFont(name: AppTypography.fontNameMedium, size: size) ?? .systemFont(ofSize: size, weight: .medium)
    }

    static func interSemiBold(_ size: CGFloat) -> UIFont {
        UIFont(name: AppTypography.fontNameSemiBold, size: size) ?? .systemFont(ofSize: size, weight: .semibold)
    }

    static func interBold(_ size: CGFloat) -> UIFont {
        UIFont(name: AppTypography.fontNameBold, size: size) ?? .systemFont(ofSize: size, weight: .bold)
    }
}
