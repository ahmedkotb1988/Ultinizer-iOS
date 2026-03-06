import Foundation
@testable import Ultinizer

final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    var requestHandler: ((APIEndpoint, (any Encodable)?, [URLQueryItem]?) async throws -> Any)?
    var uploadHandler: ((APIEndpoint, Data, String, String, String) async throws -> Any)?

    func request<T: Decodable>(
        endpoint: APIEndpoint,
        body: (any Encodable)?,
        queryItems: [URLQueryItem]?
    ) async throws -> T {
        guard let handler = requestHandler else {
            throw APIError.unknown("No mock handler set")
        }
        guard let result = try await handler(endpoint, body, queryItems) as? T else {
            throw APIError.unknown("Mock returned wrong type")
        }
        return result
    }

    func request(
        endpoint: APIEndpoint,
        body: (any Encodable)?,
        queryItems: [URLQueryItem]?
    ) async throws {
        guard let handler = requestHandler else {
            throw APIError.unknown("No mock handler set")
        }
        _ = try await handler(endpoint, body, queryItems)
    }

    func upload<T: Decodable>(
        endpoint: APIEndpoint,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String
    ) async throws -> T {
        guard let handler = uploadHandler else {
            throw APIError.unknown("No mock upload handler set")
        }
        guard let result = try await handler(endpoint, fileData, fileName, mimeType, fieldName) as? T else {
            throw APIError.unknown("Mock returned wrong type")
        }
        return result
    }
}
