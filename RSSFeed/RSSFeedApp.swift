import SwiftUI
import AppFeature
import ComposableArchitecture

@main
struct RSSFeedApp: App {
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
