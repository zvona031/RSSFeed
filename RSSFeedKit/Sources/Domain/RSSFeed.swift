import Foundation

public struct RSSFeed: Identifiable {
    public var id: URL {
        url
    }
    public let url: URL
    public let name: String
    public let description: String
    public let imageUrl: URL?
    public let items: [Item]

    public init(
        url: URL,
        name: String,
        description: String,
        imageUrl: URL?,
        items: [Item]
    ) {
        self.url = url
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.items = items
    }
}
