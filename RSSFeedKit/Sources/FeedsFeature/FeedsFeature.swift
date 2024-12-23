import ComposableArchitecture
import Domain

@Reducer
public struct FeedsFeature {

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
        case destination(PresentationAction<Destination.Action>)

        public enum ViewAction {
            case addButtonTapped
            case removeFeed(RSSFeed.ID)
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .view(.addButtonTapped):
                state.destination = .addFeed(AddFeedFeature.State())
                return .none
            case .view(.removeFeed(let id)):
                state.viewState.modify(\.content) { $0.remove(id: id) }
                return .none
            case .destination:
                return .none
            case .binding:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension FeedsFeature {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewState {
        case content(IdentifiedArrayOf<RSSFeed>)
        case error(String)
        case emptyContent(String)
        case loading
    }

    @Reducer
    public enum Destination {
        case addFeed(AddFeedFeature)
    }
}
