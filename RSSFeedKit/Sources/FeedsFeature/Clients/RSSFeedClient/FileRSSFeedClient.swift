import Dependencies
import Foundation
import IdentifiedCollections

struct FileRSSFeedClient {
    @Dependency(\.fileClient) private var fileClient

    func save(_ rssFeed: RSSFeed) throws {
        let rssFeedDto = RSSFeedDTO(rssFeed: rssFeed)
        try fileClient.save(rssFeedDto, to: .filename(absoulteString: rssFeed.url.absoluteString))
    }

    func load(from url: URL) throws -> RSSFeed {
        let rssFeedDto = try fileClient.load(RSSFeedDTO.self, from: .filename(absoulteString: url.absoluteString))
        return RSSFeed(rssFeedDto, url: url)
    }
}

extension FileRSSFeedClient {
    enum ParsingError: Error {
        case feedNotFound
    }
}

private extension String {
    static func filename(absoulteString: String) -> String {
        var filename = absoulteString
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        filename = filename.components(separatedBy: invalidCharacters).joined()
        return filename
    }
}
