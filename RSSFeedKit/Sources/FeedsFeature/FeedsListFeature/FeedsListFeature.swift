import ComposableArchitecture
import Foundation

@Reducer
public struct FeedsListFeature {
    @Dependency(\.rssFeedUrlsClient.delete) var deleteRssFeedUrl

    public init() {}

    @ObservableState
    public struct State: Equatable {
        @Shared public var feeds: IdentifiedArrayOf<FeedFeature.State>
        @Presents public var destination: Destination.State?

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

        public enum Alert: Equatable {
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
                state.destination = .details(FeedItemsListFeature.State(feed: feed, isFavorite: sharedFeed.isFavorite))
                return .none
            case .feeds:
                return .none
            case .destination(.presented(.alert(.removeConfirmation(let id)))):
                _ = state.$feeds.withLock { $0.remove(id: id) }
                deleteFeed(id: id)
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

    private func deleteFeed(id: FeedFeature.State.ID) {
        do {
            try deleteRssFeedUrl(id)
        } catch {
            print("Failed to delete feed with id \(id): \(error)")
        }
    }
}

extension FeedsListFeature {
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<FeedsListFeature.Action.Alert>)
        case details(FeedItemsListFeature)
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
