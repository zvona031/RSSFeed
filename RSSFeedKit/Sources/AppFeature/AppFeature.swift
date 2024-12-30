import ComposableArchitecture
import FeedsFeature

@Reducer
public struct AppFeature {

    public init() {}

    @ObservableState
    public struct State {
        var tab: Tab
        var feedsFeature: FeedsFeature.State
        var favoriteFeedsFeature: FavoriteFeedsFeature.State

        public init(tab: Tab = .feeds) {
            self.tab = tab
            self.feedsFeature = FeedsFeature.State()
            self.favoriteFeedsFeature = FavoriteFeedsFeature.State()
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case feedsFeature(FeedsFeature.Action)
        case favoriteFeedsFeature(FavoriteFeedsFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.feedsFeature, action: \.feedsFeature) {
            FeedsFeature()
        }

        Scope(state: \.favoriteFeedsFeature, action: \.favoriteFeedsFeature) {
            FavoriteFeedsFeature()
        }

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
            case .feedsFeature(.delegate(.favoriteStateChanged(let feedState))):
                return FavoriteFeedsFeature().reduce(into: &state.favoriteFeedsFeature, action: .favoriteStateChanged(feedState))
                    .map(Action.favoriteFeedsFeature)
            case .feedsFeature(.delegate(.feedStateChanged(let viewState, let id))):
                return FavoriteFeedsFeature().reduce(into: &state.favoriteFeedsFeature, action: .feedStateChanged(viewState, id))
                    .map(Action.favoriteFeedsFeature)
            case .favoriteFeedsFeature(.delegate(.favoriteStateChanged(let feedState))):
                return FeedsFeature().reduce(into: &state.feedsFeature, action: .favoriteStateChanged(feedState.id))
                    .map(Action.feedsFeature)
            case .favoriteFeedsFeature(.delegate(.feedStateChanged(let viewState, let id))):
                return FeedsFeature().reduce(into: &state.feedsFeature, action: .feedStateChanged(viewState, id))
                    .map(Action.feedsFeature)
            case .feedsFeature:
                return .none
            case .favoriteFeedsFeature:
                return .none
            }
        }
    }
}

extension AppFeature {
    public enum Tab {
        case feeds
        case favorites
    }
}
