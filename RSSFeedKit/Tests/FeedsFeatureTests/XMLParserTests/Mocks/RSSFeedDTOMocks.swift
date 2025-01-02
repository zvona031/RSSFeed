import FeedsFeature
import Foundation

@MainActor
enum RSSFeedDTOMocks {
    static let zeroItemsFeed = RSSFeedDTO(
        url: URL(string: "https://www.bbc.co.uk/news/world")!,
        name: "BBC News",
        description: "BBC News - World",
        imageUrl: URL(string: "https://news.bbcimg.co.uk/nol/shared/img/bbc_news_120x60.gif"),
        items: []
    )

    static let multipleItemsFeed = RSSFeedDTO(
        url: URL(string: "https://www.bbc.co.uk/news/world")!,
        name: "BBC News",
        description: "BBC News - World",
        imageUrl: URL(string: "https://news.bbcimg.co.uk/nol/shared/img/bbc_news_120x60.gif"),
        items: [
            RSSFeedDTO.ItemDTO(
                url: URL(string: "https://www.bbc.com/news/articles/c3vrzelzdrlo")!,
                title: "Could bike lanes reshape car-crazy Los Angeles?",
                description: "LA is trying to expand its cycling network ahead of the 2028 Olympics, but some are skeptical.",
                imageUrl: URL(string: "https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/39d2/live/e5809720-bee6-11ef-89fe-61878ce1042c.jpg")
            )
        ]
    )
}
