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
        let data = try await urlSession.data(from: url)
        return try mapper.map(data.0)
    }
}

extension DependencyValues {
    var rssFeedClient: RSSFeedClient {
        get { self[RSSFeedClient.self] }
        set { self[RSSFeedClient.self] = newValue}
    }
}
