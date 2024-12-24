import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct FeedsFeature {

    public init() {}

    @ObservableState
    public struct State {
        var viewState: ViewState
        @Presents var destination: Destination.State?

        public init(
            viewState: ViewState = .feedList(FeedsListFeature.State(feeds: [.init(url: URL(string: "https://feeds.bbci.co.uk/news/world/rss.xml")!, isFavorite: false)])),
            destination: Destination.State? = nil
        ) {
            self.viewState = viewState
            self.destination = destination
        }
    }

    public enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(ViewAction)
        case destination(PresentationAction<Destination.Action>)
        case feedList(FeedsListFeature.Action)

        public enum ViewAction {
            case addButtonTapped
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .view(.addButtonTapped):
                state.destination = .addFeed(AddFeedFeature.State())
                return .none
            case .destination(.presented(.addFeed(.delegate(.rssFeedAdded(let url))))):
                guard !(state.viewState.feedList?.feeds.contains(where: { $0.url == url }) ?? false) else {
                    // TODO: Add alert that displays that this RSSFeed already exists
                    state.destination = nil
                    return .none
                }
                state.viewState.modify(\.feedList) { $0.feeds.append(FeedFeature.State(url: url, isFavorite: false)) }
                state.destination = nil
                return .none
            case .destination:
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
