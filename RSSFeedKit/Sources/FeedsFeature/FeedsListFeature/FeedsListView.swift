import ComposableArchitecture
import SwiftUI

@ViewAction(for: FeedsListFeature.self)
public struct FeedsListView<ItemView: View, EmptyView: View>: View {
    @Perception.Bindable public var store: StoreOf<FeedsListFeature>
    @ViewBuilder private let itemView: (StoreOf<FeedFeature>) -> ItemView
    @ViewBuilder private let emptyView: () -> EmptyView

    public init(
        store: StoreOf<FeedsListFeature>,
        itemView: @escaping (StoreOf<FeedFeature>) -> ItemView,
        emptyView: @escaping () -> EmptyView
    ) {
        self.store = store
        self.itemView = itemView
        self.emptyView = emptyView
    }

    public var body: some View {
        WithPerceptionTracking {
            if store.feeds.isEmpty {
                emptyView()
            } else {
                ScrollView {
                    ForEach(store.scope(state: \.feeds, action: \.feeds)) { feedStore in
                        itemView(feedStore)
                            .padding()
                    }
                }
                .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
                .navigationDestination(item: $store.scope(state: \.destination?.details, action: \.destination.details)) { store in
                    FeedDetailsView(store: store)
                }
            }
        }
    }
}
