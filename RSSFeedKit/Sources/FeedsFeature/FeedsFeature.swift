import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct FeedsFeature {

    @Dependency(\.rssFeedUrlsClient) var rssFeedUrlsClient

    public init() {}

    @ObservableState
    public struct State {
        var viewState: ViewState
        @Presents var destination: Destination.State?

        public init(
            viewState: ViewState = .loading,
            destination: Destination.State? = nil
        ) {
            self.viewState = viewState
            self.destination = destination
        }
    }

    public enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(ViewAction)
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        case feedList(FeedsListFeature.Action)
        case favoriteStateChanged(FeedFeature.State.ID)
        case feedStateChanged(FeedFeature.ViewState, FeedFeature.State.ID)
        case feedStateUrlsResponse(Result<[RSSFeedModel], Error>)

        public enum ViewAction {
            case addButtonTapped
            case onTask
        }

        public enum Delegate {
            case favoriteStateChanged(FeedFeature.State)
            case feedStateChanged(FeedFeature.ViewState, FeedFeature.State.ID)
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .view(.onTask):
                return getRssFeedUrls(state: &state)
            case .view(.addButtonTapped):
                state.destination = .addFeed(AddFeedFeature.State())
                return .none
            case .favoriteStateChanged(let id):
                guard state.viewState.is(\.feedList) else { return .none }
                state.viewState.modify(\.feedList) { $0.feeds[id: id]?.isFavorite.toggle() }
                return .none
            case .destination(.presented(.addFeed(.delegate(.rssFeedAdded(let url))))):
                guard !(state.viewState.feedList?.feeds.contains(where: { $0.url == url }) ?? false) else {
                    // TODO: Add alert that displays that this RSSFeed already exists
                    state.destination = nil
                    return .none
                }
                state.viewState.modify(\.feedList) { $0.feeds.append(FeedFeature.State(url: url, isFavorite: false)) }
                state.destination = nil
                try? rssFeedUrlsClient.save(RSSFeedModel(url: url, isFavorite: false))
                return .none
            case .feedStateChanged(let viewState, let id):
                guard state.viewState.is(\.feedList) else { return .none }
                state.viewState.modify(\.feedList) { $0.feeds[id: id]?.viewState = viewState }
                return .none
            case .destination:
                return .none
            case .feedList(.delegate(.favoriteStateChanged(let feedState))):
                try? rssFeedUrlsClient.update(RSSFeedModel(url: feedState.url, isFavorite: feedState.isFavorite))
                return .send(.delegate(.favoriteStateChanged(feedState)))
            case .feedList(.delegate(.feedStateUpdated(let viewState, let id))):
                return .send(.delegate(.feedStateChanged(viewState, id)))
            case .feedStateUrlsResponse(.success(let models)):
                state.viewState = .feedList(FeedsListFeature.State(feeds: IdentifiedArray(uniqueElements: models.map({ model in
                    FeedFeature.State(url: model.url, isFavorite: model.isFavorite)
                }))))
                return .none
            case .feedStateUrlsResponse(.failure(let error)):
                state.viewState = .error("Error")
                return .none
            case .feedList:
                return .none
            case .binding:
                return .none
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.viewState.feedList, action: \.feedList) {
            FeedsListFeature()
        }
    }

    private func getRssFeedUrls(state: inout State) -> EffectOf<Self> {
        state.viewState = .loading
        return .send(.feedStateUrlsResponse(Result { try rssFeedUrlsClient.get() }))
    }
}

extension FeedsFeature {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewState {
        case feedList(FeedsListFeature.State)
        case error(String)
        case loading
    }

    @Reducer
    public enum Destination {
        case addFeed(AddFeedFeature)
    }
}
