import ComposableArchitecture
import SwiftUI

@ViewAction(for: FeedsListFeature.self)
public struct FeedsListView: View {
    public let store: StoreOf<FeedsListFeature>

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
            }

        }
    }
}
