import ComposableArchitecture
import SwiftUI

@ViewAction(for: FeedsFeature.self)
public struct FeedsView: View {
    @Perception.Bindable public var store: StoreOf<FeedsFeature>

    public init(store: StoreOf<FeedsFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                switch store.viewState {
                case .content(let feeds):
                    ForEach(feeds) { feed in
                        Text(feed.name)
                    }
                case .emptyContent(let message):
                    Text(message)
                case .error(let message):
                    Text(message)
                case .loading:
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        send(.addButtonTapped)
                    }
                }
            }
            .sheet(item: $store.scope(state: \.destination?.addFeed, action: \.destination.addFeed)) { store in
                NavigationStack {
                    AddFeedView(store: store)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("New RSS Feed")
                }
                .presentationDetents([.height(200)])
            }
        }
    }
}
