@testable import FeedsFeature
import Foundation

@MainActor
enum XMLParserMocks {
    static let zeroItems: (Data, RSSFeedDTO) = (
        DataXMLMocks.zeroItemsXml, RSSFeedDTOMocks.zeroItemsFeed
    )

    static let multipleItems: (Data, RSSFeedDTO) = (
        DataXMLMocks.multipleItemsXml, RSSFeedDTOMocks.multipleItemsFeed
    )
}
