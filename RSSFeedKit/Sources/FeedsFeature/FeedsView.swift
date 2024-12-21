import ComposableArchitecture
import SwiftUI

public struct FeedsView: View {
    private let store: StoreOf<FeedsFeature>

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
        }
    }
}
