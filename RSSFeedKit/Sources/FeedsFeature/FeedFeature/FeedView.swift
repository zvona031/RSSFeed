import ComposableArchitecture
import SwiftUI

@ViewAction(for: FeedFeature.self)
struct FeedView: View {
    let store: StoreOf<FeedFeature>

    var body: some View {
        WithPerceptionTracking {
            FeedItemView(store: store)
                .onFirstAppear {
                    send(.onTask)
                }
        }
    }
}
