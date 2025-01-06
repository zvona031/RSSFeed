import ComposableArchitecture
import Foundation
import Clients
import FeedsFeature

@Reducer
public struct SettingsFeature: Sendable {
    @Dependency(\.userNotificationClient) var userNotificationClient
    @Dependency(\.applicationClient) var applicationClient

    public init() {}

    @ObservableState
    public struct State: Sendable {
        @Shared(.newFeedItemsNotification) var newFeedItemsNotificationEnabled = false
        var isPushNotificationsWarningMessageVisible: Bool = false

        public init() {}
    }

    public enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case changeWarningMessageVisibility(Bool)
        case view(View)

        @CasePathable
        public enum View {
            case goToSettingsTapped
            case onAppear
            case onAppBecameActive
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .view(.goToSettingsTapped):
                return goToSettings()
            case .view(.onAppBecameActive), .view(.onAppear):
                return checkIfPushNotificationsAreAllowed(state: &state)
            case .changeWarningMessageVisibility(let visible):
                state.isPushNotificationsWarningMessageVisible = visible
                return .none
            case .binding(\.newFeedItemsNotificationEnabled):
                return checkIfPushNotificationsAreAllowed(state: &state)
            case .binding:
                return .none
            case .view:
                return .none
            }
        }
    }

    private func checkIfPushNotificationsAreAllowed(state: inout State) -> EffectOf<Self> {
        guard state.newFeedItemsNotificationEnabled else {
            state.isPushNotificationsWarningMessageVisible = false
            return .none
        }
        return .run { send in
            switch await userNotificationClient.getAuthorizationStatus() {
            case .notDetermined:
                let granted = try await userNotificationClient.requestAuthorization([.alert, .sound])
                await send(.changeWarningMessageVisibility(!granted))
            case .authorized:
                await send(.changeWarningMessageVisibility(false))
            default:
                await send(.changeWarningMessageVisibility(true))
            }
        }
    }

    private func goToSettings() -> EffectOf<Self> {
        .run { _ in
            guard let notificationsSettingsUrl = URL(string: applicationClient.openNotificationsSettingsURLString()) else {
                return
            }
            _ = await applicationClient.open(notificationsSettingsUrl, [:])
        }
    }
}
