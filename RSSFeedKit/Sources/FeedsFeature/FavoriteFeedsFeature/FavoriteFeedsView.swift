import ComposableArchitecture
import SwiftUI

public struct FavoriteFeedsView: View {
    @Perception.Bindable public var store: StoreOf<FeedsListFeature>

    public init(store: StoreOf<FeedsListFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            FeedsListView(store: store) { feedStore in
                FeedView(store: feedStore)
            } emptyView: {
                Text("No favorite feeds added.")
            }
        }
    }
}
