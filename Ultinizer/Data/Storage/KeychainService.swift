import Foundation
import Security

protocol KeychainServiceProtocol: Sendable {
    func getAccessToken() async throws -> String?
    func setAccessToken(_ token: String) async throws
    func getRefreshToken() async throws -> String?
    func setRefreshToken(_ token: String) async throws
    func clearTokens() async throws
}

actor KeychainService: KeychainServiceProtocol {
    private let serviceName = "com.ultinizer.app"

    private enum Keys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
    }

    func getAccessToken() throws -> String? {
        try get(key: Keys.accessToken)
    }

    func setAccessToken(_ token: String) throws {
        try set(value: token, key: Keys.accessToken)
    }

    func getRefreshToken() throws -> String? {
        try get(key: Keys.refreshToken)
    }

    func setRefreshToken(_ token: String) throws {
        try set(value: token, key: Keys.refreshToken)
    }

    func clearTokens() throws {
        try delete(key: Keys.accessToken)
        try delete(key: Keys.refreshToken)
    }

    // MARK: - Private Keychain Operations

    private func get(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.readFailed(status)
        }

        guard let data = item as? Data, let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func set(value: String, key: String) throws {
        guard let data = value.data(using: .utf8) else { return }

        // Try to update first
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            // Add new item
            var newItem = query
            newItem[kSecValueData as String] = data
            newItem[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

            let addStatus = SecItemAdd(newItem as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.writeFailed(addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.writeFailed(updateStatus)
        }
    }

    private func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.deleteFailed(status)
        }
    }
}

enum KeychainError: Error {
    case readFailed(OSStatus)
    case writeFailed(OSStatus)
    case deleteFailed(OSStatus)
}
