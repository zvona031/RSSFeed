import ComposableArchitecture
import SwiftUI
import AppFeature
import FeedsFeature

final class SceneDelegate: NSObject, UIApplicationDelegate, UIWindowSceneDelegate {
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