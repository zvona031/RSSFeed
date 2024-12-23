import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct FeedFeature {
    @ObservableState
    public struct State: Identifiable {
        public var id: URL {
            url
        }
        let url: URL
        var viewState: ViewState
        var isRequestInFlight: Bool

        public init(
            url: URL,
            viewState: ViewState = .loading,
            isRequestInFlight: Bool = false
        ) {
            self.url = url
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
            case removeButtonTapped(State.ID)
            case itemTapped(RSSFeed)
            case onTask
        }

        public enum Delegate {
            case itemTapped(RSSFeed)
            case removeButtonTapped(State.ID)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onTask):
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
            case .view(.removeButtonTapped(let id)):
                return .send(.delegate(.removeButtonTapped(id)))
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
        return .run { send in
            // TODO: add fetching of rss feed
            try await Task.sleep(nanoseconds: 3_000_000_000)
            await send(.rssFeedResponse(.success(RSSFeed(url: URL(string: "https://www.apple.com")!, name: "Name", description: "Description", imageUrl: nil, items: []))))
        }
    }
}

extension FeedFeature {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewState {
        case content(RSSFeed)
        case error
        case loading
    }
}
