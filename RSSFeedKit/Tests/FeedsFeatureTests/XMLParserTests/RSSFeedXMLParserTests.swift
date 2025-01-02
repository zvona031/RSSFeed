import Testing
import Foundation
@testable import FeedsFeature

@MainActor
struct RSSFeedXMLParserTests {
    @Test func parse_missingUrlFailure() throws {
        let parser = makeParser()
        let data = DataXMLMocks.missingUrlXml
        #expect(throws: RSSFeedParser.ParsingError.missingFeedUrl) {
            try parser.parse(data: data)
        }
    }

    @Test func parse_missingTitleFailure() throws {
        let parser = makeParser()
        let data = DataXMLMocks.missingTitleXml
        #expect(throws: RSSFeedParser.ParsingError.missingFeedTitle) {
            try parser.parse(data: data)
        }
    }

    @Test func parse_missingDescriptionFailure() throws {
        let parser = makeParser()
        let data = DataXMLMocks.missingDescriptionXml
        #expect(throws: RSSFeedParser.ParsingError.missingFeedDescription) {
            try parser.parse(data: data)
        }
    }

    @Test func parse_zeroItemsSuccess() throws {
        let parser = makeParser()
        let (data, expectedResult) = XMLParserMocks.zeroItems
        let result = try parser.parse(data: data)
        #expect(result == expectedResult)
    }

    @Test func parse_multipleItemsSuccess() throws {
        let parser = makeParser()
        let (data, expectedResult) = XMLParserMocks.multipleItems
        let result = try parser.parse(data: data)
        #expect(result == expectedResult)
    }
}

extension RSSFeedXMLParserTests {
    func makeParser() -> RSSFeedXMLParser {
        let feedParser = RSSFeedParser(itemXmlParser: FeedItemParser(), imageXmlParser: FeedImageParser())
        return RSSFeedXMLParser(feedParser: feedParser)
    }
}
