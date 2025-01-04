import Foundation

struct RSSFeedDTO: Equatable {
    let websiteUrl: URL
    let name: String
    let description: String
    let imageUrl: URL?
    let items: [ItemDTO]
}
