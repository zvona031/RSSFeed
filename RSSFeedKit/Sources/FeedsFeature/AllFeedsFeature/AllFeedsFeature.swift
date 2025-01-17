import ComposableArchitecture
import Foundation
import BackgroundTasks

@Reducer
public struct AllFeedsFeature {
    @Dependency(\.rssFeedUrlsClient) var rssFeedUrlsClient

    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var viewState: ViewState
        @Shared var feeds: IdentifiedArrayOf<FeedFeature.State>
        @Presents var destination: Destination.State?

        public init(
            feeds: Shared<IdentifiedArrayOf<FeedFeature.State>>,
            viewState: ViewState = .loading,
            destination: Destination.State? = nil
        ) {
            self._feeds = feeds
            self.viewState = viewState
            self.destination = destination
        }
    }

    public enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(ViewAction)
        case destination(PresentationAction<Destination.Action>)
        case feedList(FeedsListFeature.Action)
        case feedStateUrlsResponse(Result<[RSSFeedModel], Error>)

        @CasePathable
        @dynamicMemberLookup
        public enum ViewAction {
            case addButtonTapped
            case onFirstAppear
            case retryButtonTapped
        }

        public enum Alert: Sendable, Equatable {}
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .view(.onFirstAppear):
                return getRssFeedUrls(state: &state)
            case .view(.retryButtonTapped):
                return getRssFeedUrls(state: &state)
            case .view(.addButtonTapped):
                state.destination = .addFeed(AddFeedFeature.State())
                return .none
            case .destination(.presented(.addFeed(.delegate(.rssFeedAdded(let url))))):
                guard !(state.viewState.feedList?.feeds.contains(where: { $0.url == url }) ?? false) else {
                    state.destination = .alert(.feedAlreadyExists)
                    return .none
                }
                _ = state.$feeds.withLock { $0.append(FeedFeature.State(url: url, isFavorite: false)) }
                state.destination = nil
                saveFeed(model: RSSFeedModel(url: url, isFavorite: false))
                return .none
            case .destination:
                return .none
            case .feedStateUrlsResponse(.success(let models)):
                state.$feeds.withLock {
                    $0 = IdentifiedArray(uniqueElements: models.map({ model in
                        FeedFeature.State(url: model.url, isFavorite: model.isFavorite)
                    }))
                }
                state.viewState = .feedList(FeedsListFeature.State(feeds: state.$feeds))
                return .none
            case .feedStateUrlsResponse(.failure):
                state.viewState = .error
                return .none
            case .feedList:
                return .none
            case .binding:
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

    private func saveFeed(model: RSSFeedModel) {
        do {
            try rssFeedUrlsClient.save(model)
        } catch {
            print("Failed to save feed with id: \(model.id): \(error.localizedDescription)")
        }
    }
}

extension AllFeedsFeature {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewState: Equatable {
        case feedList(FeedsListFeature.State)
        case error
        case loading
    }

    @Reducer(state: .equatable)
    public enum Destination {
        case addFeed(AddFeedFeature)
        case alert(AlertState<AllFeedsFeature.Action.Alert>)
    }
}

extension AlertState where Action == AllFeedsFeature.Action.Alert {
    static let feedAlreadyExists = AlertState {
        TextState("Feed with this URL already exists")
    }
}
