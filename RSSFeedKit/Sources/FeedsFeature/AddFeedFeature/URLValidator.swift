import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct URLValidationClient {
    var isValid: @Sendable (_ url: String) -> Bool = { _ in true }
}

extension URLValidationClient: DependencyKey {
    static let liveValue = URLValidationClient { url in
        let regex = #"^(https:\/\/)[a-zA-Z0-9\-._~:\/?#\[\]@!$&'()*+,;=]+"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: url)
    }
}

extension DependencyValues {
    var urlValidationClient: URLValidationClient {
        get { self[URLValidationClient.self] }
        set { self[URLValidationClient.self] = newValue}
    }
}
