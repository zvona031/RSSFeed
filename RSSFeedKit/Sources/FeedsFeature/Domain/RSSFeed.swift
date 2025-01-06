import Foundation
import IdentifiedCollections

public struct RSSFeed: Identifiable, Sendable, Equatable {
    public var id: URL {
        url
    }
    let url: URL
    let websiteUrl: URL
    let name: String
    let description: String
    let imageUrl: URL?
    let lastUpdated: Date
    let items: IdentifiedArrayOf<Item>

    init(
        url: URL,
        websiteUrl: URL,
        name: String,
        description: String,
        imageUrl: URL?,
        lastUpdated: Date,
        items: IdentifiedArrayOf<Item>
    ) {
        self.url = url
        self.websiteUrl = websiteUrl
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.lastUpdated = lastUpdated
        self.items = items
    }

    init(_ feedDto: RSSFeedDTO, url: URL) {
        self.init(
            url: url,
            websiteUrl: feedDto.websiteUrl,
            name: feedDto.name,
            description: feedDto.description,
            imageUrl: feedDto.imageUrl,
            lastUpdated: feedDto.lastUpdated,
            items: IdentifiedArray(feedDto.items.map { RSSFeed.Item($0) }, uniquingIDsWith: { first, _ in first })
        )
    }
}
