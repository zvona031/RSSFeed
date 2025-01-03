import ComposableArchitecture
import FeedsFeature

@Reducer
public struct AppFeature {
    public init() {}

    @ObservableState
    public struct State {
        @Shared var feedItems: IdentifiedArrayOf<FeedFeature.State>
        var tab: Tab
        var appDelegate: AppDelegate.State
        var feeds: AllFeedsFeature.State
        var favoriteFeeds: FeedsListFeature.State

        public init(
            tab: Tab = .feeds,
            feedItems: IdentifiedArrayOf<FeedFeature.State> = [],
            appDelegate: AppDelegate.State = AppDelegate.State()
        ) {
            self.appDelegate = appDelegate
            self.tab = tab
            let sharedFeedItems = Shared(value: feedItems)
            self._feedItems = sharedFeedItems
            self.feeds = AllFeedsFeature.State(feeds: sharedFeedItems)
            self.favoriteFeeds = FeedsListFeature.State(feeds: sharedFeedItems.favoriteFeeds)
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case feeds(AllFeedsFeature.Action)
        case favoriteFeeds(FeedsListFeature.Action)
        case appDelegate(AppDelegate.Action)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.appDelegate, action: \.appDelegate) {
            AppDelegate()
        }

        Scope(state: \.feeds, action: \.feeds) {
            AllFeedsFeature()
        }

        Scope(state: \.favoriteFeeds, action: \.favoriteFeeds) {
            FeedsListFeature()
        }

        Reduce<State, Action> { _, action in
            switch action {
            case .appDelegate:
                return .none
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
