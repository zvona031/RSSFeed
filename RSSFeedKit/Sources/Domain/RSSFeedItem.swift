import Foundation

extension RSSFeed {
    public struct Item: Sendable {
        public let title: String
        public let description: String
        public let imageUrl: URL?

        public init(
            title: String,
            description: String,
            imageUrl: URL?
        ) {
            self.title = title
            self.description = description
            self.imageUrl = imageUrl
        }
    }
}
