import ComposableArchitecture
import Domain

@Reducer
public struct FeedDetailsFeature {

    public init() {}

    @ObservableState
    public struct State {
        let feed: RSSFeed
        var isFavorite: Bool

        public init(
            feed: RSSFeed,
            isFavorite: Bool
        ) {
            self.feed = feed
            self.isFavorite = isFavorite
        }
    }

    public enum Action: ViewAction {
        case view(View)
        case delegate(Delegate)

        public enum View {
            case favoriteButtonTapped
        }

        public enum Delegate {
            case favoriteButtonTapped(RSSFeed.ID)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.favoriteButtonTapped):
                state.isFavorite.toggle()
                return .send(.delegate(.favoriteButtonTapped(state.feed.id)))
            case .delegate:
                return .none
            }
        }
    }
}
