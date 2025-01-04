import SwiftUI
import AppFeature
import ComposableArchitecture
import BackgroundTasks

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
    @Dependency(\.backgroundTaskClient) var backgroundTaskClient

    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        handleBackgroundFeedRefresh()
        store.send(.appDelegate(.didFinishLaunching))
        return true
    }

    private func handleBackgroundFeedRefresh() {
        backgroundTaskClient.handleBackgroundTask(id: "com.zvonimirpavlovic.RSSFeed.feedrefresh") { [weak self] task in
            Task { @MainActor in
                self?.store.send(.appDelegate(.backgroundFeedRefresh(.onTaskTriggered(task))))
            }
        }
    }
}
