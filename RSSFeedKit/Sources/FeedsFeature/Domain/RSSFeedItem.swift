import Foundation

extension RSSFeed {
    public struct Item: Identifiable, Sendable, Equatable {
        public var id: URL {
            url
        }
        let title: String
        let description: String?
        let imageUrl: URL?
        let url: URL

        init(
            title: String,
            description: String?,
            imageUrl: URL?,
            url: URL
        ) {
            self.title = title
            self.description = description
            self.imageUrl = imageUrl
            self.url = url
        }

        init(_ feedItemDto: RSSFeedDTO.ItemDTO) {
            self.init(
                title: feedItemDto.title,
                description: feedItemDto.description,
                imageUrl: feedItemDto.imageUrl,
                url: feedItemDto.url
            )
        }
    }
}
