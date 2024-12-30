import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct FeedDetailsFeature {
    @Dependency(\.rssFeedUrlsClient) var rssFeedUrlsClient

    public init() {}

    @ObservableState
    public struct State {
        let feed: RSSFeed
        @Shared var isFavorite: Bool
        @Presents var destination: Destination.State?

        public init(
            feed: RSSFeed,
            isFavorite: Shared<Bool>,
            destination: Destination.State? = nil
        ) {
            self.feed = feed
            self._isFavorite = isFavorite
            self.destination = destination
        }
    }

    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case view(View)
        case destination(PresentationAction<Destination.Action>)

        public enum View {
            case favoriteButtonTapped
            case itemTapped(RSSFeed.Item)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.favoriteButtonTapped):
                state.$isFavorite.withLock { $0.toggle() }
                try? rssFeedUrlsClient.update(RSSFeedModel(url: state.feed.url, isFavorite: state.isFavorite))
                return .none
            case .view(.itemTapped(let item)):
                state.destination = .webView(url: item.url)
                return .none
            case .binding:
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension FeedDetailsFeature {
    @Reducer
    public enum Destination {
        @ReducerCaseIgnored
        case webView(url: URL)
    }
}
