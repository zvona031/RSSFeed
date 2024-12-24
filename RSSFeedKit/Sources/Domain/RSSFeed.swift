import Foundation
import IdentifiedCollections

public struct RSSFeed: Identifiable, Sendable {
    public var id: URL {
        url
    }
    public let url: URL
    public let name: String
    public let description: String
    public let imageUrl: URL?
    public let items: IdentifiedArrayOf<Item>

    public init(
        url: URL,
        name: String,
        description: String,
        imageUrl: URL?,
        items: IdentifiedArrayOf<Item>
    ) {
        self.url = url
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.items = items
    }
}
