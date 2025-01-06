import Dependencies
import DependenciesMacros
import Foundation
import IdentifiedCollections

@DependencyClient
struct FeedsRefreshClient: Sendable {
    var refreshFeeds: @Sendable (_ for: [URL]) async -> [RSSFeed] = { _ in [] }
}

extension FeedsRefreshClient: DependencyKey {
    public static let liveValue = FeedsRefreshClient { urls in
        @Dependency(\.rssFeedClient) var rssFeedClient
        var results: [RSSFeed?] = []

        await withTaskGroup(of: RSSFeed?.self) { [rssFeedClient] group in
            for url in urls {
                group.addTask {
                    do {
                        let rssFeed = try await rssFeedClient.get(url: url)
                        return rssFeed
                    } catch {
                        print("Fetching RSS feed with id \(url) failed: \(error.localizedDescription)")
                        return nil
                    }
                }
            }

            for await result in group {
                results.append(result)
            }
        }

        return results.compactMap { $0 }
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
        lastUpdated: Date(),
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
