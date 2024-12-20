import ComposableArchitecture

@Reducer
struct AppFeature {

    @ObservableState
    struct State {
        var tab: Tab

        init(tab: Tab = .feeds) {
            self.tab = tab
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
    }
}

extension AppFeature {
    enum Tab {
        case feeds
        case favorites
    }
}
