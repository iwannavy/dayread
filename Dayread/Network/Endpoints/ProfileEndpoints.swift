import Foundation

// MARK: - Response Wrappers

struct ProfileResponse: Codable {
    let profile: ProfilePayload
}

struct PreferencesResponse: Codable {
    let preferences: AppPreferences
}

// MARK: - Request Bodies

struct DisplayNameUpdateBody: Codable {
    let displayName: String
}

struct StateSyncBody: Codable {
    let progress: LearningProgress
}

struct SubscriptionRefreshBody: Encodable {
    let rcCustomerInfo: [String: Any]

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let data = try JSONSerialization.data(withJSONObject: rcCustomerInfo)
        let rawJSON = try JSONDecoder().decode(AnyCodable.self, from: data)
        try container.encode(rawJSON, forKey: .rcCustomerInfo)
    }

    enum CodingKeys: String, CodingKey {
        case rcCustomerInfo
    }
}

/// Type-erased Codable wrapper for arbitrary JSON values
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) { self.value = value }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map(\.value)
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues(\.value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, .init(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}

// MARK: - Endpoints

extension APIClient {
    func fetchProfile() async throws -> ProfileResponse {
        try await get("/api/me/profile")
    }

    func updateDisplayName(_ displayName: String) async throws -> ProfileResponse {
        try await patch("/api/me/profile", body: DisplayNameUpdateBody(displayName: displayName))
    }

    func fetchPreferences() async throws -> PreferencesResponse {
        try await get("/api/me/preferences")
    }

    func updatePreferences(_ patch: AppPreferences) async throws -> PreferencesResponse {
        try await post("/api/me/preferences", body: patch)
    }

    func deleteAccount() async throws {
        try await delete("/api/me/account")
    }

    func syncState(progress: LearningProgress) async throws {
        try await postVoid("/api/me/state-sync", body: StateSyncBody(progress: progress))
    }

    func refreshSubscription(customerInfo: [String: Any]) async throws -> ProfileResponse {
        try await post("/api/me/subscription/refresh", body: SubscriptionRefreshBody(rcCustomerInfo: customerInfo))
    }
}
