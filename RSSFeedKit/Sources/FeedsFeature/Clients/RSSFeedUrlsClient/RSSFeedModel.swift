import Foundation

public struct RSSFeedModel: Codable, Identifiable {
    public var id: URL {
        url
    }
    let url: URL
    let isFavorite: Bool
}
