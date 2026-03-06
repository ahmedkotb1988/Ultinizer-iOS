import Foundation
@testable import Ultinizer

actor MockKeychainService: KeychainServiceProtocol {
    var accessToken: String?
    var refreshToken: String?

    func getAccessToken() async throws -> String? { accessToken }
    func setAccessToken(_ token: String) async throws { accessToken = token }
    func getRefreshToken() async throws -> String? { refreshToken }
    func setRefreshToken(_ token: String) async throws { refreshToken = token }
    func clearTokens() async throws {
        accessToken = nil
        refreshToken = nil
    }
}
