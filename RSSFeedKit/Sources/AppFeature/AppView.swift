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
                    FeedsView(store: store.scope(state: \.feedsFeature, action: \.feedsFeature))
                        .navigationTitle("Feeds")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Text("Feeds tab")
                    Image(systemName: "newspaper.fill")
                        .renderingMode(.template)
                }
                .tag(AppFeature.Tab.feeds)

                NavigationStack() {
                    FavoriteFeedsView(store: store.scope(state: \.favoriteFeedsFeature, action: \.favoriteFeedsFeature))
                        .navigationTitle("Favorites")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Text("Favorites tab")
                    Image(systemName: "star.fill")
                        .renderingMode(.template)
                }
                .tag(AppFeature.Tab.favorites)
            }
        }
    }
}
