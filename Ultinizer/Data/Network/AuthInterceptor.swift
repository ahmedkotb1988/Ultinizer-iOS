import Foundation

actor AuthInterceptor {
    private let keychainService: KeychainServiceProtocol
    private let baseURL: URL
    private var isRefreshing = false
    private var pendingRequests: [CheckedContinuation<URLRequest?, Error>] = []
    var onSessionExpired: (@Sendable () -> Void)?

    init(keychainService: KeychainServiceProtocol, baseURL: URL) {
        self.keychainService = keychainService
        self.baseURL = baseURL
    }

    func intercept(request: URLRequest) async throws -> URLRequest {
        var mutableRequest = request
        if let token = try await keychainService.getAccessToken() {
            mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return mutableRequest
    }

    func handleUnauthorized(originalRequest: URLRequest) async throws -> URLRequest? {
        if isRefreshing {
            // Wait for the ongoing refresh
            return try await withCheckedThrowingContinuation { continuation in
                pendingRequests.append(continuation)
            }
        }

        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let newToken = try await refreshAccessToken()

            // Update the original request with new token
            var updatedRequest = originalRequest
            updatedRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")

            // Resume all pending requests
            for continuation in pendingRequests {
                var pendingRequest = originalRequest
                pendingRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                continuation.resume(returning: pendingRequest)
            }
            pendingRequests.removeAll()

            return updatedRequest
        } catch {
            // Refresh failed — clear tokens and signal session expired
            try? await keychainService.clearTokens()

            for continuation in pendingRequests {
                continuation.resume(returning: nil)
            }
            pendingRequests.removeAll()

            onSessionExpired?()
            return nil
        }
    }

    private func refreshAccessToken() async throws -> String {
        guard let refreshToken = try await keychainService.getRefreshToken() else {
            throw APIError.sessionExpired
        }

        let url = baseURL.appendingPathComponent(APIEndpoint.refreshToken.path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = RefreshTokenRequestDTO(refreshToken: refreshToken)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidToken
        }

        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(APIResponseDTO<TokenPairDTO>.self, from: data)

        guard apiResponse.success, let tokens = apiResponse.data else {
            throw APIError.invalidToken
        }

        try await keychainService.setAccessToken(tokens.accessToken)
        try await keychainService.setRefreshToken(tokens.refreshToken)

        return tokens.accessToken
    }
}

// MARK: - Supporting DTOs for refresh flow

struct RefreshTokenRequestDTO: Encodable {
    let refreshToken: String
}

struct TokenPairDTO: Codable {
    let accessToken: String
    let refreshToken: String
}
