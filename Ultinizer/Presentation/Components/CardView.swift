import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    var onTap: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    init(onTap: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.onTap = onTap
    }

    var body: some View {
        Group {
            if let onTap {
                Button(action: onTap) {
                    cardContent
                }
                .buttonStyle(CardButtonStyle())
            } else {
                cardContent
            }
        }
    }

    private var cardContent: some View {
        content
            .padding(AppSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme == .dark ? AppColors.gray800 : .white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .stroke(colorScheme == .dark ? AppColors.gray700 : AppColors.gray100, lineWidth: 1)
            )
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
