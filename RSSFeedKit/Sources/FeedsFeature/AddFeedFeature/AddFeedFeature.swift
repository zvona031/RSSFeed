import ComposableArchitecture
import Foundation

@Reducer
public struct AddFeedFeature: Reducer, Sendable {
    @Dependency(\.urlValidationClient) var urlValidationClient
    @Dependency(\.dismiss) var dismiss

    @ObservableState
    public struct State: Sendable {
        var rawUrl: String
        var errorMessage: String?
        var addButtonDisabled: Bool
        var focus: Field?

        public init(
            rawUrl: String = "",
            errorMessage: String? = nil,
            addButtonDisabled: Bool = true,
            focus: Field? = .url
        ) {
            self.rawUrl = rawUrl
            self.addButtonDisabled = addButtonDisabled
            self.focus = focus
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
            .onChange(of: \.rawUrl) { oldValue, newValue in
                Reduce { state, _ in
                    guard oldValue != newValue else { return .none }
                    return validateAddButton(state: &state)
                }
            }

        Reduce<State, Action> { state, action in
            switch action {
            case .view(.cancelButtonTapped):
                return .run { _ in
                    await dismiss()
                }
            case .view(.addButtonTapped):
                state.focus = nil
                guard let url = URL(string: state.rawUrl) else {
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

    private func validateAddButton(state: inout State) -> EffectOf<Self> {
        state.errorMessage = urlValidationClient.isValid(url: state.rawUrl) ? nil : "Please enter a valid URL"
        state.addButtonDisabled = state.errorMessage != nil
        return .none
    }
}

extension AddFeedFeature {
    public enum Field: Sendable {
        case url
    }
}
