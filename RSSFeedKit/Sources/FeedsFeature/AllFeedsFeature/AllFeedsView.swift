import ComposableArchitecture
import SwiftUI

@ViewAction(for: AllFeedsFeature.self)
public struct AllFeedsView: View {
    @Perception.Bindable public var store: StoreOf<AllFeedsFeature>

    public init(store: StoreOf<AllFeedsFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                switch store.viewState {
                case .feedList:
                    if let store = store.scope(state: \.viewState.feedList, action: \.feedList) {
                        FeedsListView(store: store) { feedStore in
                            FeedView(store: feedStore)
                                .onFirstAppear {
                                    feedStore.send(.view(.onFirstAppear))
                                }
                        } emptyView: {
                            Text("No feeds yet. Please add one.")
                        }
                    }
                case .error:
                    Button("Error") {
                        send(.retryButtonTapped)
                    }
                case .loading:
                    CircularProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        send(.addButtonTapped)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Trigger") {
                        
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
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .onFirstAppear {
                send(.onFirstAppear)
            }
        }
    }
}
