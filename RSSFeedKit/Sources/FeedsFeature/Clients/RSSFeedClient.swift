import Dependencies
import DependenciesMacros
import Domain
import Foundation

@DependencyClient
struct RSSFeedClient: Sendable {
    var get: @Sendable (_ url: URL) async throws -> RSSFeed
}

extension RSSFeedClient: DependencyKey {
    static let liveValue = RSSFeedClient { _ in
        try await Task.sleep(nanoseconds: 3_000_000_000)
        throw NSError(domain: "Dummy", code: 0)
    }
}

extension DependencyValues {
    var rssFeedClient: RSSFeedClient {
        get { self[RSSFeedClient.self] }
        set { self[RSSFeedClient.self] = newValue}
    }
}
