import ComposableArchitecture
import SwiftUI
import FeedsFeature

public struct AppView: View {
    @Perception.Bindable private var store: StoreOf<AppFeature>

    public init() {
        self.store = Store(initialState: AppFeature.State(), reducer: {
            AppFeature()
        })
    }

    public var body: some View {
        WithPerceptionTracking {
            TabView(selection: $store.tab) {
                NavigationStack() {
                    FeedsView(store: store.scope(state: \.feedsFeature, action: \.feedsFeature))
                }
                .tabItem {
                    Text("Feeds tab")
                    Image(systemName: "newspaper.fill")
                        .renderingMode(.template)
                }
                .tag(AppFeature.Tab.feeds)

                NavigationStack() {
                    Text("Favorites")
                        .navigationTitle("Favorites")
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

#Preview {
    AppView()
}