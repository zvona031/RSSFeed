import ComposableArchitecture
import SwiftUI
import FeedsFeature

public struct AppView: View {
    @Perception.Bindable private var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            TabView(selection: $store.tab) {
                NavigationStack() {
                    AllFeedsView(store: store.scope(state: \.feeds, action: \.feeds))
                        .navigationTitle("Feeds")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Text("Feeds")
                    Image(systemName: "newspaper.fill")
                        .renderingMode(.template)
                }
                .tag(AppFeature.Tab.feeds)

                NavigationStack() {
                    FavoriteFeedsView(store: store.scope(state: \.favoriteFeeds, action: \.favoriteFeeds))
                        .navigationTitle("Favorites")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Text("Favorites")
                    Image(systemName: "star.fill")
                        .renderingMode(.template)
                }
                .tag(AppFeature.Tab.favorites)
            }
        }
    }
}
