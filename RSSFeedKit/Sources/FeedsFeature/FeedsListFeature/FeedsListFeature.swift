import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct FeedsListFeature {

    @Dependency(\.rssFeedUrlsClient.delete) var deleteRssFeedUrl

    public init() {}

    @ObservableState
    public struct State {
        var feeds: IdentifiedArrayOf<FeedFeature.State>
        @Presents var destination: Destination.State?

        public init(
            feeds: IdentifiedArrayOf<FeedFeature.State>,
            destination: Destination.State? = nil
        ) {
            self.feeds = feeds
            self.destination = destination
        }
    }

    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case view(ViewAction)
        case delegate(Delegate)
        case feeds(IdentifiedActionOf<FeedFeature>)
        case destination(PresentationAction<Destination.Action>)

        public enum ViewAction {}

        public enum Alert {
            case removeConfirmation(FeedFeature.State.ID)
        }

        public enum Delegate {
            case favoriteStateChanged(FeedFeature.State)
            case feedRemoved(FeedFeature.State.ID)
            case feedStateUpdated(FeedFeature.ViewState, FeedFeature.State.ID)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .feeds(.element(id: let id, action: .delegate(.removeButtonTapped))):
                state.destination = .alert(AlertState {
                    TextState("Do you really want to remove this feed?")
                } actions: {
                    ButtonState {
                        TextState("No")
                    }
                    ButtonState(action: .removeConfirmation(id)) {
                        TextState("Yes")
                    }
                })
                return .none
            case .feeds(.element(id: let id, action: .delegate(.favoriteButtonTapped))):
                return favoriteButtonTapped(state: &state, id: id)
            case .feeds(.element(id: _, action: .delegate(.itemTapped(let rssFeed, let isFavorite)))):
                state.destination = .details(FeedDetailsFeature.State(feed: rssFeed, isFavorite: isFavorite))
                return .none
            case .feeds(.element(id: let id, action: .delegate(.itemUpdated(let viewState)))):
                return .send(.delegate(.feedStateUpdated(viewState, id)))
            case .feeds:
                return .none
            case .destination(.presented(.alert(.removeConfirmation(let id)))):
                let feedState = state.feeds.remove(id: id)
                try? deleteRssFeedUrl(id)
                return .send(.delegate(.feedRemoved(id)))
            case .destination(.presented(.details(.delegate(.favoriteButtonTapped(let id))))):
                return favoriteButtonTapped(state: &state, id: id)
            case .destination:
                return .none
            case .binding:
                return .none
            case .delegate:
                return .none
            }
        }
        .forEach(\.feeds, action: \.feeds) {
            FeedFeature()
        }
        .ifLet(\.$destination, action: \.destination)
    }

    private func favoriteButtonTapped(state: inout State, id: FeedFeature.State.ID) -> EffectOf<Self> {
        state.feeds[id: id]?.isFavorite.toggle()
        guard let feed = state.feeds[id: id] else { return .none }
        return .send(.delegate(.favoriteStateChanged(feed)))
    }
}

extension FeedsListFeature {
    @Reducer
    public enum Destination {
        case alert(AlertState<FeedsListFeature.Action.Alert>)
        case details(FeedDetailsFeature)
    }
}
