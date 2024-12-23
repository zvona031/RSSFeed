import ComposableArchitecture
import FeedsFeature

@Reducer
struct AppFeature {

    @ObservableState
    struct State {
        var tab: Tab
        var feedsFeature: FeedsFeature.State

        init(tab: Tab = .feeds) {
            self.tab = tab
            self.feedsFeature = FeedsFeature.State()
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case feedsFeature(FeedsFeature.Action)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.feedsFeature, action: \.feedsFeature) {
            FeedsFeature()
        }
    }
}

extension AppFeature {
    enum Tab {
        case feeds
        case favorites
    }
}
