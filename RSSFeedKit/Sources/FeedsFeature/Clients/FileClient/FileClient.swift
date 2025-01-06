import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct FileClient: Sendable {
    var load: @Sendable (String) throws -> Data
    var save: @Sendable (String, Data) throws -> Void
    var fileExists: @Sendable (_ at: String) -> Bool = { _ in false }

    func load<A: Decodable>(_ type: A.Type, from fileName: String) throws -> A {
      try JSONDecoder().decode(A.self, from: self.load(fileName))
    }

    func save<A: Encodable>(_ data: A, to fileName: String) throws {
      try self.save(fileName, JSONEncoder().encode(data))
    }
}

extension FileClient: DependencyKey {
    public static let liveValue = {
      let documentDirectory = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first!

      return Self(
        load: {
            try Data(
                contentsOf: documentDirectory.appendingPathComponent($0).appendingPathExtension("json")
            )
        },
        save: {
            try $1.write(
              to: documentDirectory.appendingPathComponent($0).appendingPathExtension("json")
            )
        },
        fileExists: {
            FileManager.default.fileExists(
                atPath: documentDirectory.appendingPathComponent($0).appendingPathExtension("json").path()
            )
        }
      )
    }()

    static let testValue = Self(
        load: { _ in
            Data("".utf8)
        },
        save: { _, _ in },
        fileExists: { _ in true }
      )
}

extension DependencyValues {
    var fileClient: FileClient {
        get { self[FileClient.self] }
        set { self[FileClient.self] = newValue }
    }
}
