import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct FeedsListFeature {
    @Dependency(\.rssFeedUrlsClient.delete) var deleteRssFeedUrl

    public init() {}

    @ObservableState
    public struct State {
        @Shared var feeds: IdentifiedArrayOf<FeedFeature.State>
        @Presents var destination: Destination.State?

        public init(
            feeds: Shared<IdentifiedArrayOf<FeedFeature.State>>,
            destination: Destination.State? = nil
        ) {
            self._feeds = feeds
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
                state.destination = .alert(.deleteConfirmation(id: id))
                return .none
            case .feeds(.element(id: let id, action: .delegate(.itemTapped(let feed)))):
                guard let sharedFeed = Shared(state.$feeds[id: id].projectedValue) else {
                    return .none
                }

                state.destination = .details(FeedDetailsFeature.State(feed: feed, isFavorite: sharedFeed.isFavorite))
                return .none
            case .feeds:
                return .none
            case .destination(.presented(.alert(.removeConfirmation(let id)))):
                _ = state.$feeds.withLock { $0.remove(id: id) }
                try? deleteRssFeedUrl(id)
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

extension AlertState where Action == FeedsListFeature.Action.Alert {
    static func deleteConfirmation(id: FeedFeature.State.ID) -> AlertState {
        AlertState {
            TextState("Do you really want to remove this feed?")
        } actions: {
            ButtonState {
                TextState("No")
            }
            ButtonState(action: .removeConfirmation(id)) {
                TextState("Yes")
            }
        }
    }
}
