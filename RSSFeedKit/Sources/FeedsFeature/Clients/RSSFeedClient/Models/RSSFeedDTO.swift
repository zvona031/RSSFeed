import Foundation

public struct RSSFeedDTO: Equatable {
    public let url: URL
    public let name: String
    public let description: String
    public let imageUrl: URL?
    public let items: [ItemDTO]

    public init(
        url: URL,
        name: String,
        description: String,
        imageUrl: URL?,
        items: [ItemDTO]
    ) {
        self.url = url
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.items = items
    }
}
