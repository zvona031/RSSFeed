import Foundation

extension RSSFeedDTO {
    public struct ItemDTO: Equatable {
        public let url: URL
        public let title: String
        public let description: String?
        public let imageUrl: URL?

        public init(
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
    }
}
