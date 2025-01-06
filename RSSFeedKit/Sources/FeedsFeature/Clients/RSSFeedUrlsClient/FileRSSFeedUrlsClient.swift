import Foundation
import Dependencies

struct FileRSSFeedURLClient {
    private let filename: String
    @Dependency(\.fileClient) private var fileClient

    init(filename: String) {
        self.filename = filename
    }

    func save(_ rssFeedModels: [RSSFeedModel]) throws {
        try fileClient.save(rssFeedModels, to: filename)
    }

    func load() throws -> [RSSFeedModel] {
        guard fileClient.fileExists(at: filename) else {
            return []
        }
        return try fileClient.load([RSSFeedModel].self, from: filename)
    }
}
