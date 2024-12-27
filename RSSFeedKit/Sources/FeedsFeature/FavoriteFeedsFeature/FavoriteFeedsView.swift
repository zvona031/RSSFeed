import ComposableArchitecture
import SwiftUI

@ViewAction(for: FavoriteFeedsFeature.self)
public struct FavoriteFeedsView: View {
    @Perception.Bindable public var store: StoreOf<FavoriteFeedsFeature>

    public init(store: StoreOf<FavoriteFeedsFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                switch store.viewState {
                case .feedList:
                    if let store = store.scope(state: \.viewState.feedList, action: \.feedList) {
                        FeedsListView(store: store) { feedStore in
                            FeedItemView(store: feedStore)
                        } emptyView: {
                            Text("No favorite feeds added.")
                        }
                    }
                case .error(let message):
                    Text(message)
                case .loading:
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .onFirstAppear {
                send(.onTask)
            }
        }
    }
}
