import Foundation

struct RSSFeedDTO: Equatable {
    let url: URL
    let name: String
    let description: String
    let imageUrl: URL?
    let items: [ItemDTO]
}
