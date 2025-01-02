import Foundation

extension RSSFeed {
    public struct Item: Identifiable, Sendable {
        public var id: URL {
            url
        }
        public let title: String
        public let description: String?
        public let imageUrl: URL?
        public let url: URL

        public init(
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
    }
}
