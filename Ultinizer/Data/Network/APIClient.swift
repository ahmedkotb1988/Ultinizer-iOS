import Foundation

protocol APIClientProtocol: Sendable {
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        body: (any Encodable)?,
        queryItems: [URLQueryItem]?
    ) async throws -> T

    func request(
        endpoint: APIEndpoint,
        body: (any Encodable)?,
        queryItems: [URLQueryItem]?
    ) async throws

    func upload<T: Decodable>(
        endpoint: APIEndpoint,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String
    ) async throws -> T
}

extension APIClientProtocol {
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        body: (any Encodable)? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        try await request(endpoint: endpoint, body: body, queryItems: queryItems)
    }

    func request(
        endpoint: APIEndpoint,
        body: (any Encodable)? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws {
        try await request(endpoint: endpoint, body: body, queryItems: queryItems)
    }
}

final class APIClient: APIClientProtocol, @unchecked Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let authInterceptor: AuthInterceptor
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL, authInterceptor: AuthInterceptor) {
        self.baseURL = baseURL
        self.authInterceptor = authInterceptor

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = ISO8601DateFormatter.full.date(from: dateString) {
                return date
            }
            if let date = ISO8601DateFormatter.withoutMilliseconds.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(dateString)")
        }

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    func request<T: Decodable>(
        endpoint: APIEndpoint,
        body: (any Encodable)?,
        queryItems: [URLQueryItem]?
    ) async throws -> T {
        let data = try await performRequest(endpoint: endpoint, body: body, queryItems: queryItems)
        do {
            let response = try decoder.decode(APIResponseDTO<T>.self, from: data)
            if response.success, let responseData = response.data {
                return responseData
            } else if let error = response.error {
                throw APIError.from(code: error.code, message: error.message)
            } else {
                throw APIError.unknown("Request failed with no data")
            }
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }

    func request(
        endpoint: APIEndpoint,
        body: (any Encodable)?,
        queryItems: [URLQueryItem]?
    ) async throws {
        let data = try await performRequest(endpoint: endpoint, body: body, queryItems: queryItems)
        do {
            let response = try decoder.decode(APIResponseDTO<EmptyData>.self, from: data)
            if !response.success, let error = response.error {
                throw APIError.from(code: error.code, message: error.message)
            }
        } catch let apiError as APIError {
            throw apiError
        } catch {
            // If decoding fails but request succeeded, that's fine for void requests
        }
    }

    func upload<T: Decodable>(
        endpoint: APIEndpoint,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var bodyData = Data()
        bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        bodyData.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        bodyData.append(fileData)
        bodyData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = bodyData

        request = try await authInterceptor.intercept(request: request)

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            if let retryRequest = try await authInterceptor.handleUnauthorized(originalRequest: request) {
                let (retryData, _) = try await session.data(for: retryRequest)
                return try decodeResponse(from: retryData)
            }
            throw APIError.sessionExpired
        }

        return try decodeResponse(from: data)
    }

    // MARK: - Private

    private func performRequest(
        endpoint: APIEndpoint,
        body: (any Encodable)?,
        queryItems: [URLQueryItem]?
    ) async throws -> Data {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)!
        if let queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.networkError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        // Auth interception (adds token)
        let isAuthEndpoint = [
            APIEndpoint.login.path,
            APIEndpoint.register.path,
            APIEndpoint.refreshToken.path,
            APIEndpoint.forgotPassword.path,
            APIEndpoint.resetPassword.path,
        ].contains(endpoint.path)

        if !isAuthEndpoint {
            request = try await authInterceptor.intercept(request: request)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError("Invalid response")
        }

        // Handle 401 with token refresh
        if httpResponse.statusCode == 401 && !isAuthEndpoint {
            if let retryRequest = try await authInterceptor.handleUnauthorized(originalRequest: request) {
                let (retryData, _) = try await session.data(for: retryRequest)
                return retryData
            }
            throw APIError.sessionExpired
        }

        return data
    }

    private func decodeResponse<T: Decodable>(from data: Data) throws -> T {
        do {
            let response = try decoder.decode(APIResponseDTO<T>.self, from: data)
            if response.success, let responseData = response.data {
                return responseData
            } else if let error = response.error {
                throw APIError.from(code: error.code, message: error.message)
            } else {
                throw APIError.unknown("Request failed")
            }
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }
}

// MARK: - Helpers

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ wrapped: any Encodable) {
        _encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

struct EmptyData: Codable {}

extension ISO8601DateFormatter {
    static let full: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let withoutMilliseconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
