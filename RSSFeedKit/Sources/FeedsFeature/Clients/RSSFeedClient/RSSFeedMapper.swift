import DependenciesMacros
import Dependencies
import Foundation
import IdentifiedCollections

struct RSSFeedMapper {
    var map: @Sendable (Data) throws -> RSSFeed
}

extension RSSFeedMapper: DependencyKey {
    static let liveValue = RSSFeedMapper { data in
        let feedParser = RSSFeedParser(itemXmlParser: FeedItemParser(), imageXmlParser: FeedImageParser())
        let parser = RSSFeedXMLParser(feedParser: feedParser)
        let feedDto = try parser.parse(data: data)
        return RSSFeed(feedDto)
    }
}

extension DependencyValues {
    var rssFeedMapper: RSSFeedMapper {
        get { self[RSSFeedMapper.self] }
        set { self[RSSFeedMapper.self] = newValue}
    }
}

fileprivate extension RSSFeed.Item {
    init(_ feedItemDto: RSSFeedDTO.ItemDTO) {
        self.init(
            title: feedItemDto.title,
            description: feedItemDto.description,
            imageUrl: feedItemDto.imageUrl,
            url: feedItemDto.url
        )
    }
}

fileprivate extension RSSFeed {
    init(_ feedDto: RSSFeedDTO) {
        self.init(
            url: feedDto.url,
            name: feedDto.name,
            description: feedDto.description,
            imageUrl: feedDto.imageUrl,
            items: IdentifiedArray(feedDto.items.map { RSSFeed.Item($0) }, uniquingIDsWith: { first, _ in first })
        )
    }
}
