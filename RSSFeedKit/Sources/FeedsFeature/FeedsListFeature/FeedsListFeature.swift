import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct FeedsListFeature {

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
        case feeds(IdentifiedActionOf<FeedFeature>)
        case destination(PresentationAction<Destination.Action>)

        public enum ViewAction {}

        public enum Alert {
            case removeConfirmation(FeedFeature.State.ID)
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
                state.feeds[id: id]?.isFavorite.toggle()
                return .none
            case .feeds(.element(id: _, action: .delegate(.itemTapped(let rssFeed, let isFavorite)))):
                state.destination = .details(FeedDetailsFeature.State(feed: rssFeed, isFavorite: isFavorite))
                return .none
            case .feeds:
                return .none
            case .destination(.presented(.alert(.removeConfirmation(let id)))):
                state.feeds.remove(id: id)
                return .none
            case .destination(.presented(.details(.delegate(.favoriteButtonTapped(let id))))):
                state.feeds[id: id]?.isFavorite.toggle()
                return .none
            case .destination:
                return .none
            case .binding:
                return .none
            }
        }
        .forEach(\.feeds, action: \.feeds) {
            FeedFeature()
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension FeedsListFeature {
    @Reducer
    public enum Destination {
        case alert(AlertState<FeedsListFeature.Action.Alert>)
        case details(FeedDetailsFeature)
    }
}
