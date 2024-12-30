import ComposableArchitecture
import FeedsFeature

@Reducer
public struct AppFeature {

    public init() {}

    @ObservableState
    public struct State {
        @Shared var feedItems: IdentifiedArrayOf<FeedFeature.State>
        var tab: Tab
        var feeds: FeedsFeature.State
        var favoriteFeeds: FeedsListFeature.State

        public init(
            tab: Tab = .feeds,
            feedItems: IdentifiedArrayOf<FeedFeature.State> = []
        ) {
            self.tab = tab
            let sharedFeedItems = Shared(value: feedItems)
            self._feedItems = sharedFeedItems
            self.feeds = FeedsFeature.State(feeds: sharedFeedItems)
            self.favoriteFeeds = FeedsListFeature.State(feeds: sharedFeedItems.favoriteFeeds)
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case feeds(FeedsFeature.Action)
        case favoriteFeeds(FeedsListFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.feeds, action: \.feeds) {
            FeedsFeature()
        }

        Scope(state: \.favoriteFeeds, action: \.favoriteFeeds) {
            FeedsListFeature()
        }

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
            case .feeds:
                return .none
            case .favoriteFeeds:
                return .none
            }
        }
    }
}

extension AppFeature {
    public enum Tab {
        case feeds
        case favorites
    }
}
