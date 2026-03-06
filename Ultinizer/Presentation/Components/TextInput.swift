import SwiftUI

struct TextInput: View {
    let label: String?
    let placeholder: String
    @Binding var text: String
    var error: String?
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isMultiline: Bool = false
    var minHeight: CGFloat? = nil

    @State private var isSecureVisible = false
    @FocusState private var isFocused: Bool

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if let label {
                Text(label)
                    .font(AppTypography.labelSemiBold)
                    .foregroundColor(colorScheme == .dark ? AppColors.gray300 : AppColors.gray700)
            }

            HStack {
                if isMultiline {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(3...8)
                        .frame(minHeight: minHeight ?? 80, alignment: .topLeading)
                        .font(AppTypography.body)
                        .textInputAutocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                        .focused($isFocused)
                } else if isSecure && !isSecureVisible {
                    SecureField(placeholder, text: $text)
                        .font(AppTypography.body)
                        .textContentType(textContentType)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .font(AppTypography.body)
                        .textInputAutocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .autocorrectionDisabled(keyboardType == .emailAddress)
                        .focused($isFocused)
                }

                if isSecure {
                    Button(action: { isSecureVisible.toggle() }) {
                        Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                            .foregroundColor(AppColors.gray400)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, AppSpacing.inputPaddingH)
            .padding(.vertical, AppSpacing.inputPaddingV)
            .background(colorScheme == .dark ? AppColors.gray800 : .white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(borderColor, lineWidth: 1)
            )

            if let error, !error.isEmpty {
                Text(error)
                    .font(AppTypography.label)
                    .foregroundColor(AppColors.red500)
            }
        }
        .padding(.bottom, AppSpacing.md)
    }

    private var borderColor: Color {
        if let error, !error.isEmpty {
            return AppColors.red500
        }
        if isFocused {
            return AppColors.magenta500
        }
        return colorScheme == .dark ? AppColors.gray700 : AppColors.gray200
    }
}
