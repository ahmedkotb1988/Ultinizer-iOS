import Foundation

struct AppSpacing {
    static let xxs: CGFloat = 2    // 0.5
    static let xs: CGFloat = 4     // 1
    static let sm: CGFloat = 6     // 1.5
    static let md: CGFloat = 8     // 2
    static let mdPlus: CGFloat = 10 // 2.5
    static let lg: CGFloat = 12    // 3
    static let xl: CGFloat = 16    // 4
    static let xxl: CGFloat = 20   // 5
    static let xxxl: CGFloat = 24  // 6
    static let huge: CGFloat = 32  // 8
    static let giant: CGFloat = 40 // 10
    static let fabBottom: CGFloat = 96 // 24

    // Named spacing for specific uses
    static let screenHorizontal: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let sectionGap: CGFloat = 24
    static let inputPaddingH: CGFloat = 16
    static let inputPaddingV: CGFloat = 12
    static let labelMarginBottom: CGFloat = 6
}

struct AppRadius {
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let xxl: CGFloat = 20
    static let full: CGFloat = 9999
}

struct AppShadow {
    struct Values {
        let x: CGFloat
        let y: CGFloat
        let radius: CGFloat
        let opacity: Double
    }

    static let sm = Values(x: 0, y: 1, radius: 2, opacity: 0.05)
    static let md = Values(x: 0, y: 2, radius: 4, opacity: 0.1)
    static let lg = Values(x: 0, y: 4, radius: 8, opacity: 0.1)
    static let xl = Values(x: 0, y: 8, radius: 16, opacity: 0.12)
}
