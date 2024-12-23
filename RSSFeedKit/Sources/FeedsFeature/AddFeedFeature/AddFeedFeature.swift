import ComposableArchitecture
import Foundation

@Reducer
public struct AddFeedFeature: Reducer, Sendable {
    @Dependency(\.dismiss) var dismiss

    @ObservableState
    public struct State: Sendable {
        var rawUrl: String
        var destination: Destination?
        var addButtonEnabled: Bool

        public init(
            rawUrl: String = "",
            destination: Destination? = nil,
            addButtonEnabled: Bool = false
        ) {
            self.rawUrl = rawUrl
            self.destination = destination
            self.addButtonEnabled = addButtonEnabled
        }
    }

    public enum Action: BindableAction, ViewAction, Sendable {
        case binding(BindingAction<State>)
        case view(View)
        case delegate(Delegate)

        public enum View: Sendable {
            case cancelButtonTapped
            case addButtonTapped
        }

        public enum Delegate: Sendable {
            case rssFeedAdded(URL)
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .view(.cancelButtonTapped):
                return .run { _ in
                    await dismiss()
                }
            case .view(.addButtonTapped):
                guard let url = URL(string: state.rawUrl) else {
                    // TODO: add alert for invalid URL
                    return .none
                }
                return .run { send in
                    await send(.delegate(.rssFeedAdded(url)))
                }
            case .binding:
                return .none
            case .delegate:
                return .none
            }
        }
    }
}

extension AddFeedFeature {
    @Reducer
    public enum Destination: Sendable {
        case alert(AlertState<Alert>)

        public enum Alert: Sendable {
            case success
            case error
        }
    }
}
