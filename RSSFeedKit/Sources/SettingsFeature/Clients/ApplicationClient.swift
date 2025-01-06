import DependenciesMacros
import Dependencies
import UIKit

@DependencyClient
struct UIApplicationClient: Sendable {
    var open: @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool = { _, _ in false }
    var openNotificationsSettingsURLString: @Sendable () -> String = { "" }
}

extension UIApplicationClient: DependencyKey {
    static let liveValue = Self(
        open: { @MainActor in await UIApplication.shared.open($0, options: $1) },
        openNotificationsSettingsURLString: { UIApplication.openNotificationSettingsURLString }
    )
}

extension DependencyValues {
    var applicationClient: UIApplicationClient {
        get { self[UIApplicationClient.self] }
        set { self[UIApplicationClient.self] = newValue }
    }
}
