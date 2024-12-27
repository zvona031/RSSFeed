import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct FavoriteFeedsFeature {

    @Dependency(\.rssFeedUrlsClient) var rssFeedUrlsClient

    public init() {}

    @ObservableState
    public struct State {
        var viewState: ViewState

        public init(
            viewState: ViewState = .loading
        ) {
            self.viewState = viewState
        }
    }

    public enum Action: BindableAction, ViewAction {
        case view(View)
        case binding(BindingAction<State>)
        case delegate(Delegate)
        case feedList(FeedsListFeature.Action)
        case favoriteStateChanged(FeedFeature.State)
        case feedStateChanged(FeedFeature.ViewState, FeedFeature.State.ID)
        case feedStateUrlsResponse(Result<[RSSFeedModel], Error>)

        public enum Delegate {
            case favoriteStateChanged(FeedFeature.State)
            case feedStateChanged(FeedFeature.ViewState, FeedFeature.State.ID)
        }

        public enum View {
            case onTask
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .view(.onTask):
                return getFavoriteRssFeedUrls(state: &state)
            case .feedList(.delegate(.favoriteStateChanged(let feedState))):
                guard state.viewState.is(\.feedList) else { return .none }
                if !feedState.isFavorite {
                    state.viewState.modify(\.feedList) { $0.feeds.remove(feedState) }
                }
                return .send(.delegate(.favoriteStateChanged(feedState)))
            case .feedList(.delegate(.feedStateUpdated(let viewState, let id))):
                return .send(.delegate(.feedStateChanged(viewState, id)))
            case .feedList:
                return .none
            case .favoriteStateChanged(let feedState):
                guard state.viewState.is(\.feedList) else { return .none }
                state.viewState.modify(\.feedList) { feedList in
                    if feedList.feeds.contains(feedState) {
                        feedList.feeds.remove(feedState)
                    } else {
                        feedList.feeds.append(feedState)
                    }
                }
                return .none
            case .feedStateChanged(let viewState, let id):
                guard state.viewState.is(\.feedList) else { return .none }
                state.viewState.modify(\.feedList) { $0.feeds[id: id]?.viewState = viewState }
                return .none
            case .feedStateUrlsResponse(.success(let models)):
                state.viewState = .feedList(FeedsListFeature.State(feeds: IdentifiedArray(uniqueElements: models.map({ model in
                    FeedFeature.State(url: model.url, isFavorite: model.isFavorite)
                }))))
                return .none
            case .feedStateUrlsResponse(.failure(let error)):
                state.viewState = .error("Error")
                return .none
            case .binding:
                return .none
            case .delegate:
                return .none
            }
        }
        .ifLet(\.viewState.feedList, action: \.feedList) {
            FeedsListFeature()
        }
    }

    private func getFavoriteRssFeedUrls(state: inout State) -> EffectOf<Self> {
         state.viewState = .loading
        return .send(.feedStateUrlsResponse(Result { try rssFeedUrlsClient.get().filter { $0.isFavorite } }))
     }
}

extension FavoriteFeedsFeature {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewState {
        case feedList(FeedsListFeature.State)
        case error(String)
        case loading
    }
}
