import DependenciesMacros
import Dependencies
import Domain
import Foundation

struct RSSFeedMapper {
    var map: @Sendable (Data) throws -> RSSFeed
}

extension RSSFeedMapper: DependencyKey {
    static let liveValue = RSSFeedMapper { data in
        let parser = RSSFeedXMLParserDelegate()
        return try parser.parse(data: data)
    }
}

extension DependencyValues {
    var rssFeedMapper: RSSFeedMapper {
        get { self[RSSFeedMapper.self] }
        set { self[RSSFeedMapper.self] = newValue}
    }
}
