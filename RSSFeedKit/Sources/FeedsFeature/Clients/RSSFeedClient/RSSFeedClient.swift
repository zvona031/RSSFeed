import Dependencies
import DependenciesMacros
import Foundation
import IdentifiedCollections

@DependencyClient
struct RSSFeedClient: Sendable {
    var get: @Sendable (_ url: URL) async throws -> RSSFeed
}

extension RSSFeedClient: DependencyKey {
    static let liveValue = RSSFeedClient { url in
        @Dependency(\.urlSession) var urlSession
        @Dependency(\.rssFeedMapper) var mapper
        let cacheRssFeedClient = FileRSSFeedClient(encoder: JSONEncoder(), decoder: JSONDecoder())
        do {
            let data = try await urlSession.data(from: url)
            let feed = try mapper.map(data.0, url)
            try? cacheRssFeedClient.save(feed)
            return feed
        } catch {
            let cachedFeed = try cacheRssFeedClient.load(from: url)
            return cachedFeed
        }
    }
}

extension DependencyValues {
    var rssFeedClient: RSSFeedClient {
        get { self[RSSFeedClient.self] }
        set { self[RSSFeedClient.self] = newValue}
    }
}
