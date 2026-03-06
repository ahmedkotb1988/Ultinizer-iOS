import Foundation

struct APIResponseDTO<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: APIErrorDTO?
    let meta: APIMetaDTO?
}

struct APIErrorDTO: Decodable {
    let code: String
    let message: String
    let details: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case code, message, details
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(String.self, forKey: .code)
        message = try container.decode(String.self, forKey: .message)
        details = try container.decodeIfPresent(AnyCodable.self, forKey: .details)
    }
}

struct APIMetaDTO: Decodable {
    let limit: Int?
    let cursor: String?
    let hasMore: Bool?
}

// MARK: - AnyCodable for dynamic `details` field

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal.map { $0.value }
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intVal = value as? Int {
            try container.encode(intVal)
        } else if let doubleVal = value as? Double {
            try container.encode(doubleVal)
        } else if let boolVal = value as? Bool {
            try container.encode(boolVal)
        } else if let stringVal = value as? String {
            try container.encode(stringVal)
        } else {
            try container.encodeNil()
        }
    }
}

// MARK: - Paginated Response

struct PaginatedResponseDTO<T: Decodable>: Decodable {
    let success: Bool
    let data: [T]?
    let error: APIErrorDTO?
    let meta: APIMetaDTO?
}

// MARK: - Message Response

struct MessageResponseDTO: Decodable {
    let message: String
}
