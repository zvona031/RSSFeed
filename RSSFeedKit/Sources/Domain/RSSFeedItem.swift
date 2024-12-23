import Foundation

extension RSSFeed {
    public struct Item: Sendable {
        public let title: String
        public let description: String
        public let imageUrl: URL
    }
}
