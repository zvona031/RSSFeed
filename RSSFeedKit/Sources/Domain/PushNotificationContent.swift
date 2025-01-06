public enum PushNotificationContent: Codable {
    case rssFeedItemUpdated(String)

    private enum CodingKeys: String, CodingKey {
        case type
        case payload
    }

    private enum CaseType: String {
        case rssFeedItemUpdated
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .rssFeedItemUpdated(let value):
            try container.encode(CaseType.rssFeedItemUpdated.rawValue, forKey: .type)
            try container.encode(value, forKey: .payload)
        }
    }


    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let rawType = try container.decode(String.self, forKey: .type)
        guard let type = CaseType(rawValue: rawType) else {
            throw DecodingError
            .dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Data corrupted"))
        }

        switch type {
        case .rssFeedItemUpdated:
            let value = try container.decode(String.self, forKey: .payload)
            self = .rssFeedItemUpdated(value)
        }
    }
}
