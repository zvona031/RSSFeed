import DependenciesMacros
import Dependencies
import Foundation
import IdentifiedCollections

struct RSSFeedMapper {
    var map: @Sendable (Data, URL) throws -> RSSFeed
}

extension RSSFeedMapper: DependencyKey {
    static let liveValue = RSSFeedMapper { data, url in
        let feedParser = RSSFeedParser(itemXmlParser: FeedItemParser(), imageXmlParser: FeedImageParser())
        let parser = RSSFeedXMLParser(feedParser: feedParser)
        let feedDto = try parser.parse(data: data)
        return RSSFeed(feedDto, url: url)
    }
}

extension DependencyValues {
    var rssFeedMapper: RSSFeedMapper {
        get { self[RSSFeedMapper.self] }
        set { self[RSSFeedMapper.self] = newValue}
    }
}
