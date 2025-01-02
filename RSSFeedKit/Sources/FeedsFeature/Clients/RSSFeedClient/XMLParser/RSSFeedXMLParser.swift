import Foundation

class RSSFeedXMLParser: NSObject, XMLParserDelegate {
    let feedParser: RSSFeedParser

    init(feedParser: RSSFeedParser) {
        self.feedParser = feedParser
    }

    func parse(data: Data) throws -> RSSFeedDTO {
        let parser = XMLParser(data: data)
        parser.delegate = self

        return if parser.parse() {
            try feedParser.parse()
        } else if let error = parser.parserError {
            throw error
        } else {
            throw ParsingError.unknown
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        feedParser.didStartElement(elementName: elementName, attributes: attributeDict)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        feedParser.foundCharacters(string: string)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        feedParser.didEndElement(elementName: elementName)
    }
}

extension RSSFeedXMLParser {
    enum ParsingError: Error {
        case unknown
    }
}
