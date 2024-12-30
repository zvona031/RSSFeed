import Dependencies
import DependenciesMacros
import Domain
import Foundation
import IdentifiedCollections

@DependencyClient
struct RSSFeedClient: Sendable {
    var get: @Sendable (_ url: URL) async throws -> RSSFeed
}

extension RSSFeedClient: DependencyKey {
    static let liveValue = RSSFeedClient { url in
        @Dependency(\.urlSession) var urlSession
        let parser = RSSFeedXMLParserDelegate(url: url)
        let data = try await urlSession.data(from: url)
        let rssFeed = try parser.parse(data: data.0, url: url)
        return rssFeed
    }
}

extension DependencyValues {
    var rssFeedClient: RSSFeedClient {
        get { self[RSSFeedClient.self] }
        set { self[RSSFeedClient.self] = newValue}
    }
}

class RSSFeedXMLParserDelegate: NSObject, XMLParserDelegate {
    private var feedUrl: URL
    private var currentElement: String = ""
    private var currentTitle: String = ""
    private var currentDescription: String = ""
    private var currentImageUrl: URL?
    private var currentUrl: URL?
    var items: IdentifiedArrayOf<RSSFeed.Item> = []

    private var feedName: String = ""
    private var feedDescription: String = ""
    private var feedImageUrl: URL?
    private var isParsingItem: Bool = false

    init(url: URL) {
        self.feedUrl = url
    }

    func parse(data: Data, url: URL) throws -> RSSFeed {
        let parser = XMLParser(data: data)
        parser.delegate = self

        if parser.parse() {
            return RSSFeed(
                url: url,
                name: self.feedName,
                description: self.feedDescription,
                imageUrl: self.feedImageUrl,
                items: self.items
            )
        } else if let error = parser.parserError {
            throw error
        } else {
            throw NSError(domain: "Unknown error", code: 0)
        }
    }
    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            isParsingItem = true
            currentTitle = ""
            currentDescription = ""
            currentImageUrl = nil
            currentUrl = nil
        } else if currentElement == Element.media.rawValue {
            currentImageUrl = URL(string: attributeDict[Element.url.rawValue] ?? "")
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        switch currentElement {
        case Element.title.rawValue:
            if isParsingItem, currentTitle.isEmpty {
                currentTitle += trimmedString
            } else if feedName.isEmpty {
                feedName += trimmedString
            }
        case Element.description.rawValue:
            if isParsingItem, currentDescription.isEmpty {
                currentDescription += trimmedString
            } else if feedDescription.isEmpty {
                feedDescription += trimmedString
            }
        case Element.url.rawValue:
            if feedImageUrl == nil, let url = URL(string: trimmedString) {
                feedImageUrl = url
            }
        case Element.link.rawValue:
            if isParsingItem, currentUrl == nil, let url = URL(string: trimmedString) {
                currentUrl = url
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item", let url = currentUrl {
            let item = RSSFeed.Item(
                title: currentTitle,
                description: currentDescription,
                imageUrl: currentImageUrl,
                url: url
            )
            items.append(item)
            isParsingItem = false
        }
    }

    private enum Element: String {
        case title
        case description
        case image
        case url
        case item
        case media = "media:thumbnail"
        case link
    }
}
