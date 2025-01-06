import Foundation

extension RSSFeedDTO {
    struct ItemDTO: Equatable, Codable {
        let url: URL
        let title: String
        let description: String?
        let imageUrl: URL?

        init(
            url: URL,
            title: String,
            description: String?,
            imageUrl: URL?
        ) {
            self.url = url
            self.title = title
            self.description = description
            self.imageUrl = imageUrl
        }

        init(item: RSSFeed.Item) {
            self.url = item.url
            self.title = item.title
            self.description = item.description
            self.imageUrl = item.imageUrl
        }
    }
}
