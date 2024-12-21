import ComposableArchitecture
import Domain

@Reducer
public struct FeedsFeature {

    public init() {}

    @ObservableState
    public struct State {
        var viewState: ViewState

        public init(viewState: ViewState = .loading) {
            self.viewState = viewState
        }
    }

    public enum Action: ViewAction {
        case view(ViewAction)

        public enum ViewAction {
            case addButtonTapped
            case removeFeed(RSSFeed.ID)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.addButtonTapped):
                // TODO: implement
                return .none
            case .view(.removeFeed(let id)):
                state.viewState.modify(\.content) { $0.remove(id: id) }
                return .none
            }
        }
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
}
