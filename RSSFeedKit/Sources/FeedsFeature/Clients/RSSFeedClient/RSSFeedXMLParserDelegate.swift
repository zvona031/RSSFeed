import Domain
import Foundation
import IdentifiedCollections

class RSSFeedXMLParserDelegate: NSObject, XMLParserDelegate {
    private var feedUrl: URL?
    private var feedName: String?
    private var feedDescription: String?
    private var feedImageUrl: URL?

    private var currentElement: Element?

    private var isParsingItem: Bool = false
    private var currentItem = Item()
    var items: IdentifiedArrayOf<RSSFeed.Item> = []

    func parse(data: Data) throws -> RSSFeed {
        let parser = XMLParser(data: data)
        parser.delegate = self

        if parser.parse() {
            guard let feedUrl, let feedName, let feedDescription else {
                throw ParsingError.requiredFieldsMissing
            }
            return RSSFeed(
                url: feedUrl,
                name: feedName,
                description: feedDescription,
                imageUrl: feedImageUrl,
                items: self.items
            )
        } else if let error = parser.parserError {
            throw error
        } else {
            throw ParsingError.unknown
        }
    }
    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = Element(rawValue: elementName)
        if currentElement == .item {
            isParsingItem = true
            currentItem.reset()
        } else if currentElement == .media,
                  let url = attributeDict[Element.url.rawValue] {
            currentItem.imageUrl = URL(string: url)
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        switch currentElement {
        case .title:
            if isParsingItem, currentItem.title == nil {
                currentItem.title = trimmedString
            } else if feedName == nil {
                feedName = trimmedString
            }
        case .description:
            if isParsingItem, currentItem.description == nil {
                currentItem.description = trimmedString
            } else if feedDescription == nil {
                feedDescription = trimmedString
            }
        case .url:
            if feedImageUrl == nil, let url = URL(string: trimmedString) {
                feedImageUrl = url
            }
        case .link:
            if isParsingItem, currentItem.url == nil, let url = URL(string: trimmedString) {
                currentItem.url = url
            } else if feedUrl == nil, let url = URL(string: trimmedString) {
                feedUrl = url
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let endElement = Element(rawValue: elementName),
              endElement == .item else {
            return
        }
        isParsingItem = false
        if let feedItem = currentItem.toFeedItem() {
            items.append(feedItem)
        }
    }
}

extension RSSFeedXMLParserDelegate {
    private struct Item {
        var url: URL?
        var title: String?
        var description: String?
        var imageUrl: URL?

        mutating func reset() {
            self = Item()
        }

        func toFeedItem() -> RSSFeed.Item? {
            guard let url,
                  let title,
                  let description else { return nil }
            return RSSFeed.Item(title: title, description: description, imageUrl: imageUrl, url: url)
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

    enum ParsingError: Error {
        case unknown
        case requiredFieldsMissing
    }
}
