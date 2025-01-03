import SwiftUI
import AppFeature
import ComposableArchitecture

@main
struct RSSFeedApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: self.appDelegate.store)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    func application(
      _ application: UIApplication,
      // swiftlint:disable:next discouraged_optional_collection
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        store.send(.appDelegate(.didFinishLaunching))
      return true
    }
}
