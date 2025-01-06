import Dependencies
import Foundation
import IdentifiedCollections

struct FileRSSFeedClient {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    @Dependency(\.dataClient) private var dataClient

    init(encoder: JSONEncoder, decoder: JSONDecoder) {
        self.encoder = encoder
        self.decoder = decoder
    }

    func save(_ rssFeed: RSSFeed) throws {
        let rssFeedDto = RSSFeedDTO(rssFeed: rssFeed)
        let data = try encoder.encode(rssFeedDto)
        try dataClient.save(data: data, url: .rssFeedUrl(absoulteString: rssFeed.url.absoluteString))
    }

    func load(from url: URL) throws -> RSSFeed {
        let data = try dataClient.load(url: .rssFeedUrl(absoulteString: url.absoluteString))
        let rssFeedDto = try decoder.decode(RSSFeedDTO.self, from: data)
        return RSSFeed(rssFeedDto, url: url)
    }
}

extension FileRSSFeedClient {
    enum ParsingError: Error {
        case feedNotFound
    }
}

private extension URL {
    static func rssFeedUrl(absoulteString: String) -> URL {
        var filename = absoulteString

        // Sanitize the filename to ensure it's valid for file storage
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        filename = filename.components(separatedBy: invalidCharacters).joined()

        return Self.documentsDirectory.appending(component: filename)
    }
}
