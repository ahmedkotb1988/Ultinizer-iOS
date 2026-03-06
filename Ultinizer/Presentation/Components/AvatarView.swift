import SwiftUI

enum AvatarSize {
    case sm, md, lg, xl

    var dimension: CGFloat {
        switch self {
        case .sm: return 32
        case .md: return 40
        case .lg: return 56
        case .xl: return 80
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .sm: return AppTypography.sizeXS
        case .md: return AppTypography.sizeSM
        case .lg: return AppTypography.sizeLG
        case .xl: return AppTypography.size2XL
        }
    }
}

struct AvatarView: View {
    let name: String
    var imageURL: URL?
    var size: AvatarSize = .md

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        initialsView
                    case .empty:
                        ProgressView()
                            .tint(AppColors.magenta500)
                    @unknown default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle())
    }

    private var initialsView: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? AppColors.magenta900 : AppColors.magenta100)
            Text(initials)
                .font(AppTypography.semiBold(size.fontSize))
                .foregroundColor(colorScheme == .dark ? AppColors.magenta300 : AppColors.magenta700)
        }
    }

    private var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}
