protocol XMLDataParser {
    associatedtype Model
    func parse() throws -> Model
    func didStartElement(elementName: String, attributes attributeDict: [String: String])
    func foundCharacters(string: String)
    func didEndElement(elementName: String)
}
