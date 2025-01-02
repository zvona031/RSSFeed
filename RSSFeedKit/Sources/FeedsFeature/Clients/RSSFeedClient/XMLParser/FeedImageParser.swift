import Foundation

class FeedImageParser: XMLFeedParser {
    private var currentElement: Element?
    var url: URL?

    func parse() throws -> URL {
        defer {
            currentElement = nil
            url = nil
        }
        guard let url else {
            throw ParsingError.missingImageUrlField
        }
        return url
    }

    func didStartElement(elementName: String, attributes attributeDict: [String : String]) {
        currentElement = Element(rawValue: elementName)
    }
    
    func foundCharacters(string: String) {
        guard let currentElement else { return }
        switch currentElement {
        case .url:
            guard url == nil else { break }
            url = URL(string: string)
        }
    }
    
    func didEndElement(elementName: String) {}
    
    private enum Element: String {
        case url
    }

    private enum ParsingError: Error {
        case missingImageUrlField
    }
}
