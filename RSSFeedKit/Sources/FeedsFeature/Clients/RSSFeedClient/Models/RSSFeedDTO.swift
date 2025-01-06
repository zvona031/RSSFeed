import Foundation

struct RSSFeedDTO: Equatable, Codable {
    let websiteUrl: URL
    let name: String
    let description: String
    let imageUrl: URL?
    let lastUpdated: Date
    let items: [ItemDTO]

    init(
        websiteUrl: URL,
        name: String,
        description: String,
        imageUrl: URL?,
        lastUpdated: Date,
        items: [ItemDTO]
    ) {
        self.websiteUrl = websiteUrl
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.lastUpdated = lastUpdated
        self.items = items
    }

    init(rssFeed: RSSFeed) {
        self.websiteUrl = rssFeed.websiteUrl
        self.name = rssFeed.name
        self.description = rssFeed.description
        self.imageUrl = rssFeed.imageUrl
        self.lastUpdated = rssFeed.lastUpdated
        self.items = rssFeed.items.map { RSSFeedDTO.ItemDTO(item: $0) }
    }
}
