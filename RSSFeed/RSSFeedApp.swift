import SwiftUI
import AppFeature

@main
struct RSSFeedApp: App {
    @UIApplicationDelegateAdaptor(SceneDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: self.appDelegate.store)
        }
    }
}
