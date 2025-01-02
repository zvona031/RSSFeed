import SwiftUI
import Foundation

public struct ItemView: View {
    private let url: URL?
    private let title: String
    private let description: String?

    public init(
        url: URL?,
        title: String,
        description: String?
    ) {
        self.url = url
        self.title = title
        self.description = description
    }

    public var body: some View {
        HStack {
            AsyncImage(url: url)
                .frame(width: 60, height: 60)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)

                if let description, !description.isEmpty {
                    Text(description)
                        .font(.body)
                }
            }
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
    }
}

#Preview {
    ItemView(url: nil, title: "Short title", description: nil)
}
