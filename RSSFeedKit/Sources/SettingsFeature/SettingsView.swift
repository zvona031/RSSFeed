import ComposableArchitecture
import SwiftUI

@ViewAction(for: SettingsFeature.self)
public struct SettingsView: View {
    @Perception.Bindable public var store: StoreOf<SettingsFeature>
    @Environment(\.scenePhase) private var scenePhase

    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            if store.isPushNotificationsWarningMessageVisible {
                HStack {
                    Text("Push notifications are disabled in the")
                        .font(.footnote)
                    Text("settings")
                        .font(.footnote)
                        .underline()
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            send(.goToSettingsTapped)
                        }
                }
            }
            ScrollView {
                Toggle(
                    "Get notified about new feed items",
                    isOn: $store.newFeedItemsNotificationEnabled
                )
                .padding()
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .active:
                    send(.onAppBecameActive)
                default:
                    return
                }
            }

            .onAppear {
                send(.onAppear)
            }
        }
    }
}
