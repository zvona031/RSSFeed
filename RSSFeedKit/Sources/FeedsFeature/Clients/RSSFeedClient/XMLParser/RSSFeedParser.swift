import Foundation

class RSSFeedParser: XMLFeedParser {
    private let itemXmlParser: FeedItemParser
    private let imageXmlParser: FeedImageParser

    private var currentElement: Element?
    private var rssFeed = RSSFeed()

    init(
        itemXmlParser: FeedItemParser,
        imageXmlParser: FeedImageParser
    ) {
        self.itemXmlParser = itemXmlParser
        self.imageXmlParser = imageXmlParser
    }

    func parse() throws -> RSSFeedDTO {
        defer {
            currentElement = nil
            rssFeed.reset()
        }

        return try rssFeed.toRSSFeedDTO()
    }

    func didStartElement(elementName: String, attributes attributeDict: [String: String]) {
        switch currentElement {
        case .image:
            imageXmlParser.didStartElement(elementName: elementName, attributes: attributeDict)
        case .item:
            itemXmlParser.didStartElement(elementName: elementName, attributes: attributeDict)
        default:
            currentElement = Element(rawValue: elementName)
        }
    }

    func foundCharacters(string: String) {
        guard let currentElement else {
            return
        }
        let trimmedString = string.trimmingCharacters(in: .newlines)

        switch currentElement {
        case .image:
            imageXmlParser.foundCharacters(string: trimmedString)
        case .item:
            itemXmlParser.foundCharacters(string: trimmedString)
        case .title:
            if rssFeed.title == nil {
                rssFeed.title = trimmedString
            } else {
                rssFeed.title?.append(trimmedString)
            }
        case .description:
            if rssFeed.description == nil {
                rssFeed.description = trimmedString
            } else {
                rssFeed.description?.append(trimmedString)
            }
        case .link:
            guard let url = URL(string: trimmedString),
                  rssFeed.websiteUrl == nil else { break }
            rssFeed.websiteUrl = url
        default:
            break
        }
    }

    func didEndElement(elementName: String) {
        guard let endElement = Element(rawValue: elementName) else {
            return
        }

        switch endElement {
        case .image:
            currentElement = nil
            do {
                rssFeed.imageUrl = try imageXmlParser.parse()
            } catch {
                print("Error parsing image: \(error)")
            }
        case .item:
            currentElement = nil
            do {
                let item = try itemXmlParser.parse()
                rssFeed.items.append(item)
            } catch {
                print("Error parsing item: \(error)")
            }
        default:
            break
        }
    }

    private enum Element: String {
        case title
        case description
        case image
        case link
        case url
        case item
    }

    private struct RSSFeed {
        var websiteUrl: URL?
        var title: String?
        var description: String?
        var imageUrl: URL?
        var items: [RSSFeedDTO.ItemDTO] = []

        func toRSSFeedDTO() throws -> RSSFeedDTO {
            guard let websiteUrl else {
                throw ParsingError.missingFeedUrl
            }
            guard let title else {
                throw ParsingError.missingFeedTitle
            }
            guard let description else {
                throw ParsingError.missingFeedDescription
            }
            return RSSFeedDTO(
                websiteUrl: websiteUrl,
                name: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                imageUrl: imageUrl,
                items: items
            )
        }

        mutating func reset() {
            self = RSSFeed()
        }
    }

    enum ParsingError: Error {
        case missingFeedUrl
        case missingFeedTitle
        case missingFeedDescription
    }
}
