import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct FeedsListFeature {

    public init() {}

    @ObservableState
    public struct State {
        var feeds: IdentifiedArrayOf<FeedFeature.State>

        public init(
            feeds: IdentifiedArrayOf<FeedFeature.State>
        ) {
            self.feeds = feeds
        }
    }

    public enum Action: ViewAction {
        case view(ViewAction)
        case feeds(IdentifiedActionOf<FeedFeature>)

        public enum ViewAction {
            case removeFeed(IndexSet)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.removeFeed(let indexSet)):
                state.feeds.remove(atOffsets: indexSet)
                return .none
            case .feeds:
                return .none
            }
        }
        .forEach(\.feeds, action: \.feeds) {
            FeedFeature()
        }
    }
}
