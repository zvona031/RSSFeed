import ComposableArchitecture
import SwiftUI

@ViewAction(for: FeedsListFeature.self)
public struct FeedsListView: View {
    @Perception.Bindable public var store: StoreOf<FeedsListFeature>

    public var body: some View {
        WithPerceptionTracking {
            if store.feeds.isEmpty {
                Text("No feeds")
            } else {
                ScrollView {
                    ForEach(store.scope(state: \.feeds, action: \.feeds)) { feedStore in
                        FeedView(store: feedStore)
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
