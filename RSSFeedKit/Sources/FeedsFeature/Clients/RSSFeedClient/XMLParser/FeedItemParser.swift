import Foundation

class FeedItemParser: XMLFeedParser {
    private var currentElement: Element?
    private var item = Item()

    func parse() throws -> RSSFeedDTO.ItemDTO {
        defer {
            currentElement = nil
            item.reset()
        }
        return try item.toFeedItem()
    }

    func didStartElement(elementName: String, attributes attributeDict: [String: String]) {
        currentElement = Element(rawValue: elementName)
        guard let currentElement else {
            return
        }

        switch currentElement {
        case .mediaThumbnail:
            guard let url = attributeDict[Attribute.url.rawValue],
                  item.imageUrl == nil else { break }
            item.imageUrl = URL(string: url)
        default:
            break
        }
    }
    
    func foundCharacters(string: String) {
        guard let currentElement else {
            return
        }
        switch currentElement {
        case .title:
            if item.title == nil {
                item.title = string
            } else {
                item.title?.append(string)
            }
        case .description:
            if item.description == nil {
                item.description = string
            } else {
                item.description?.append(string)
            }
        case .link:
            guard let url = URL(string: string),
                  item.url == nil else { break }
            item.url = url
        default:
            break
        }
    }
    
    func didEndElement(elementName: String) {}
    
    private enum Element: String {
        case title
        case description
        case link
        case mediaThumbnail = "media:thumbnail"
        case mediaContent = "media:content"
    }

    private enum Attribute: String {
        case url
    }

    private struct Item {
        var url: URL?
        var title: String?
        var description: String?
        var imageUrl: URL?

        mutating func reset() {
            self = Item()
        }

        func toFeedItem() throws -> RSSFeedDTO.ItemDTO {
            guard let url else {
                throw ParsingError.missingItemUrl
            }
            guard let title else {
                throw ParsingError.missingItemTitle
            }
            return RSSFeedDTO.ItemDTO(
                url: url,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description?.trimmingCharacters(in: .whitespacesAndNewlines),
                imageUrl: imageUrl
            )
        }
    }

    private enum ParsingError: Error {
        case missingItemUrl
        case missingItemTitle
    }
}
