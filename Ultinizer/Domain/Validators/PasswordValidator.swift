import Foundation

struct PasswordValidator {
    struct ValidationResult {
        let isValid: Bool
        let errors: [String]
    }

    static func validate(_ password: String) -> ValidationResult {
        var errors: [String] = []

        if password.count < 8 {
            errors.append("Password must be at least 8 characters")
        }

        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }

    static func validateEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }
}
