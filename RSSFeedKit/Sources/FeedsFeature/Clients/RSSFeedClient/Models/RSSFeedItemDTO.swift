import Foundation

extension RSSFeedDTO {
    struct ItemDTO: Equatable {
        let url: URL
        let title: String
        let description: String?
        let imageUrl: URL?
    }
}
