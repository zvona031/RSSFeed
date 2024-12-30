import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct DataClient: Sendable {
    var save: @Sendable (_ data: Data, _ url: URL) throws -> Void
    var load: @Sendable (_ url: URL) throws -> Data
    var fileExists: @Sendable (_ at: String) -> Bool = { _ in false }
}

extension DataClient: DependencyKey {
    static let liveValue = DataClient { data, url in
        try data.write(to: url)
    } load: { url in
        try Data(contentsOf: url)
    } fileExists: { path in
        FileManager.default.fileExists(atPath: path)
    }
}

extension DependencyValues {
    var dataClient: DataClient {
        get { self[DataClient.self] }
        set { self[DataClient.self] = newValue}
    }
}
