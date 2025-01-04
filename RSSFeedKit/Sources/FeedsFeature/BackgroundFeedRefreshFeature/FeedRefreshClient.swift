import Dependencies
import DependenciesMacros
import Foundation
import IdentifiedCollections

@DependencyClient
struct FeedsRefreshClient: Sendable {
    var refreshFeeds: @Sendable (_ for: [URL]) async -> [Result<RSSFeed, Error>] = { _ in [] }
}

extension FeedsRefreshClient: DependencyKey {
    public static let liveValue = FeedsRefreshClient { urls in
        @Dependency(\.rssFeedClient) var rssFeedClient
        var results: [Result<RSSFeed, Error>] = []

        await withTaskGroup(of: Result<RSSFeed, Error>.self) { [rssFeedClient] group in
            for url in urls {
                group.addTask {
                    do {
                        let rssFeed = try await rssFeedClient.get(url: url)
                        return .success(.updatedBBC)
                    } catch {
                        return .failure(error)
                    }
                }
            }

            for await result in group {
                results.append(result)
            }
        }

        return results
    }
}

extension DependencyValues {
    var feedsRefreshClient: FeedsRefreshClient {
        get { self[FeedsRefreshClient.self] }
        set { self[FeedsRefreshClient.self] = newValue }
    }
}

extension RSSFeed {
    static let updatedBBC = RSSFeed(
        url: URL(string: "https://feeds.bbci.co.uk/news/world/rss.xml")!,
        websiteUrl: URL(string: "https://www.bbc.co.uk/news/world")!,
        name: "BBC News",
        description: "BBC News - World",
        imageUrl: URL(string: "https://news.bbcimg.co.uk/nol/shared/img/bbc_news_120x60.gif"),
        items: IdentifiedArray(
            uniqueElements: [
                RSSFeed.Item(
                    title: "new item",
                    description: nil,
                    imageUrl: nil,
                    url: URL(
                        string: "www.dummyNewUrl.com"
                    )!
                )
            ]
        )
    )
}
