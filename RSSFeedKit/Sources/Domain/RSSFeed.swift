import Foundation

public struct RSSFeed: Identifiable {
    public let id: UUID
    public let url: URL
    public let name: String
    public let description: String
    public let imageUrl: URL
    public let items: [Item]
}
