import Foundation

public struct RSSFeedModel: Codable, Identifiable, Sendable {
    public var id: URL {
        url
    }
    let url: URL
    let isFavorite: Bool
}
