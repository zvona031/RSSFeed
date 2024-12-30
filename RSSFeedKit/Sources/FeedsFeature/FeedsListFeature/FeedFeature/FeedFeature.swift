import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct FeedFeature: Sendable {
    @Dependency(\.rssFeedClient) var rssFeedClient
    @Dependency(\.rssFeedUrlsClient) var rssFeedUrlsClient

    @ObservableState
    public struct State: Identifiable, Sendable {
        public var id: URL {
            url
        }
        let url: URL
        var viewState: ViewState
        var isFavorite: Bool
        var isRequestInFlight: Bool

        public init(
            url: URL,
            isFavorite: Bool,
            viewState: ViewState = .loading,
            isRequestInFlight: Bool = false
        ) {
            self.url = url
            self.isFavorite = isFavorite
            self.viewState = viewState
            self.isRequestInFlight = isRequestInFlight
        }
    }

    public enum Action: ViewAction {
        case view(View)
        case delegate(Delegate)
        case rssFeedResponse(Result<RSSFeed, Error>)

        public enum View {
            case retryButtonTapped
            case refreshButtonTapped
            case removeButtonTapped
            case favoriteButtonTapped
            case itemTapped(RSSFeed)
            case onFirstAppear
        }

        public enum Delegate {
            case itemTapped(RSSFeed)
            case removeButtonTapped
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onFirstAppear):
                state.viewState = .loading
                return fetchRssFeed(state: &state)
            case .view(.retryButtonTapped):
                state.viewState = .loading
                return fetchRssFeed(state: &state)
            case .view(.refreshButtonTapped):
                state.isRequestInFlight = true
                return fetchRssFeed(state: &state)
            case .view(.itemTapped(let rssFeed)):
                return .send(.delegate(.itemTapped(rssFeed)))
            case .view(.removeButtonTapped):
                return .send(.delegate(.removeButtonTapped))
            case .view(.favoriteButtonTapped):
                state.isFavorite.toggle()
                try? rssFeedUrlsClient.update(RSSFeedModel(url: state.url, isFavorite: state.isFavorite))
                return .none
            case .rssFeedResponse(.success(let rssFeed)):
                state.isRequestInFlight = false
                state.viewState = .content(rssFeed)
                return .none
            case .rssFeedResponse(.failure):
                state.isRequestInFlight = false
                state.viewState = .error
                return .none
            case .delegate:
                return .none
            }
        }
    }

    private func fetchRssFeed(state: inout State) -> EffectOf<Self> {
        .run { [url = state.url] send in
            await send(.rssFeedResponse(Result { try await rssFeedClient.get(url: url) }))
        }
    }
}

extension FeedFeature {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewState: Sendable {
        case content(RSSFeed)
        case error
        case loading
    }
}
