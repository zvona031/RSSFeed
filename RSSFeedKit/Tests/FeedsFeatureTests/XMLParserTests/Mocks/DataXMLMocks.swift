import Foundation

enum DataXMLMocks {
    static let missingUrlXml = Data(StringXMLMocks.missingUrlRawXml.utf8)
    static let missingTitleXml = Data(StringXMLMocks.missingTitleRawXml.utf8)
    static let missingDescriptionXml = Data(StringXMLMocks.missingDescriptionRawXml.utf8)
    static let zeroItemsXml = Data(StringXMLMocks.zeroItemsRawXml.utf8)
    static let multipleItemsXml = Data(StringXMLMocks.multipleItemsRawXml.utf8)
}
