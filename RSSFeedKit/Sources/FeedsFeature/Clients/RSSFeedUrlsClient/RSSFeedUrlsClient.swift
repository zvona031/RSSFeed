import DependenciesMacros
import Dependencies
import Domain
import Foundation

@DependencyClient
public struct RSSFeedUrlsClient: Sendable {
    public var get: @Sendable () throws -> [RSSFeedModel]
    public var save: @Sendable (RSSFeedModel) throws -> Void
    public var delete: @Sendable (RSSFeedModel.ID) throws -> Void
    public var update: @Sendable (RSSFeedModel) throws -> Void
}

extension RSSFeedUrlsClient: DependencyKey {
    public enum RSSFeedUrlsClientError: Error {
        case itemNotFound
    }

    public static var liveValue: RSSFeedUrlsClient {
        let fileRssFeedUrlsClient = FileRSSFeedURLClient(encoder: JSONEncoder(), decoder: JSONDecoder(), url: .rssFeedUrls)
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
    }
}

extension DependencyValues {
    public var rssFeedUrlsClient: RSSFeedUrlsClient {
        get { self[RSSFeedUrlsClient.self] }
        set { self[RSSFeedUrlsClient.self] = newValue}
    }
}

private extension URL {
    static let rssFeedUrls = Self.documentsDirectory.appending(component: "rssFeedUrls.json")
}
