import Foundation
import Dependencies

struct FileRSSFeedURLClient {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let url: URL
    @Dependency(\.dataClient) private var dataClient

    init(encoder: JSONEncoder, decoder: JSONDecoder, url: URL) {
        self.encoder = encoder
        self.decoder = decoder
        self.url = url
    }

    func save(_ reminders: [RSSFeedModel]) throws {
        let data = try encoder.encode(reminders)
        try dataClient.save(data: data, url: url)
    }

    func load() throws -> [RSSFeedModel] {
        guard dataClient.fileExists(at: url.path()) else {
            return []
        }
        let data = try dataClient.load(url: url)
        let reminders = try decoder.decode([RSSFeedModel].self, from: data)
        return reminders
    }
}
