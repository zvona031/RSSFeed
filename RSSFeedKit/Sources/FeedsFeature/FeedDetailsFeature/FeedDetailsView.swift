import ComposableArchitecture
import Kingfisher
import SwiftUI

@ViewAction(for: FeedDetailsFeature.self)
public struct FeedDetailsView: View {
    public let store: StoreOf<FeedDetailsFeature>

    public init(store: StoreOf<FeedDetailsFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                ForEach(store.feed.items) { feedItem in
                    HStack {
                        KFImage(feedItem.imageUrl)
                            .placeholder {
                                Color.gray.cornerRadius(5)
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                        
                        VStack(alignment: .leading) {
                            Text(feedItem.title)
                                .font(.headline)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.leading, 8)
                            if !feedItem.description.isEmpty {
                                Text(feedItem.description)
                                    .font(.body)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .padding(.leading, 8)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.white) // Background color for the item
                    .cornerRadius(10) // Rounded corners
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Optional shadow
                    .padding()

                }
            }
            .navigationTitle(store.feed.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        send(.favoriteButtonTapped)
                    } label: {
                        Image(systemName: store.isFavorite ? "star.fill" : "star")
                    }
                }
            }
        }
    }
}
