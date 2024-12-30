import ComposableArchitecture
import Domain

@Reducer
public struct FeedDetailsFeature {

    @Dependency(\.rssFeedUrlsClient) var rssFeedUrlsClient

    public init() {}

    @ObservableState
    public struct State {
        let feed: RSSFeed
        @Shared var isFavorite: Bool

        public init(
            feed: RSSFeed,
            isFavorite: Shared<Bool>
        ) {
            self.feed = feed
            self._isFavorite = isFavorite
        }
    }

    public enum Action: ViewAction {
        case view(View)

        public enum View {
            case favoriteButtonTapped
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.favoriteButtonTapped):
                state.$isFavorite.withLock { $0.toggle() }
                try? rssFeedUrlsClient.update(RSSFeedModel(url: state.feed.url, isFavorite: state.isFavorite))
                return .none
            }
        }
    }
}
