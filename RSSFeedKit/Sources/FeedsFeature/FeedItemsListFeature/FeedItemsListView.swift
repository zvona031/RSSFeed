import ComposableArchitecture
import Kingfisher
import SwiftUI

@ViewAction(for: FeedItemsListFeature.self)
public struct FeedItemsListView: View {
    @Perception.Bindable public var store: StoreOf<FeedItemsListFeature>

    public init(store: StoreOf<FeedItemsListFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                ForEach(store.feed.items) { feedItem in
                    ItemView(url: feedItem.imageUrl, title: feedItem.title, description: feedItem.description)
                        .padding(4)
                        .roundedShadow()
                        .padding()
                        .onTapGesture {
                            send(.itemTapped(feedItem))
                        }
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
            .sheet(item: $store.scope(state: \.destination?.webView, action: \.destination.webView)) { store in
                store.withState { url in
                    WebView(url: url)
                }
            }
        }
    }
}
