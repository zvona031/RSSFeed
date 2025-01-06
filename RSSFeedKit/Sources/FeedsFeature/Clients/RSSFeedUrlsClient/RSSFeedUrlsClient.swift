import DependenciesMacros
import Dependencies
import Foundation

@DependencyClient
struct RSSFeedUrlsClient: Sendable {
    var get: @Sendable () throws -> [RSSFeedModel]
    var save: @Sendable (RSSFeedModel) throws -> Void
    var delete: @Sendable (RSSFeedModel.ID) throws -> Void
    var update: @Sendable (RSSFeedModel) throws -> Void
}

extension RSSFeedUrlsClient: DependencyKey {
    enum RSSFeedUrlsClientError: Error {
        case itemNotFound
    }

    static let liveValue = {
        let fileRssFeedUrlsClient = FileRSSFeedURLClient(filename: .rssFeedUrls)
        return RSSFeedUrlsClient {
            try fileRssFeedUrlsClient.load()
        } save: { feedModel in
            var feedUrls = try fileRssFeedUrlsClient.load()
            feedUrls.append(feedModel)
            try fileRssFeedUrlsClient.save(feedUrls)
        } delete: { id in
            var feedUrls = try fileRssFeedUrlsClient.load()
            guard let index = feedUrls.firstIndex(where: { $0.id == id }) else { throw RSSFeedUrlsClientError.itemNotFound }
            feedUrls.remove(at: index)
            try fileRssFeedUrlsClient.save(feedUrls)
        } update: { feedModel in
            var feedUrls = try fileRssFeedUrlsClient.load()
            guard let index = feedUrls.firstIndex(where: { $0.url == feedModel.url }) else { throw RSSFeedUrlsClientError.itemNotFound }
            feedUrls[index] = feedModel
            try fileRssFeedUrlsClient.save(feedUrls)
        }
    }()

    static let testValue = RSSFeedUrlsClient {
        []
    } save: { _ in
    } delete: { _ in
    } update: { _ in
    }
}

extension DependencyValues {
    var rssFeedUrlsClient: RSSFeedUrlsClient {
        get { self[RSSFeedUrlsClient.self] }
        set { self[RSSFeedUrlsClient.self] = newValue}
    }
}

private extension String {
    static let rssFeedUrls = "rssFeedUrls"
}
