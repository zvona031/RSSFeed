import Testing
import Foundation
import Dependencies
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
        let feedParser = withDependencies {
            $0.date.now = Date(timeIntervalSince1970: 1234567890)
          } operation: {
              RSSFeedParser(itemXmlParser: FeedItemParser(), imageXmlParser: FeedImageParser())
          }

        return RSSFeedXMLParser(feedParser: feedParser)
    }
}
