import ComposableArchitecture
import FeedsFeature
import Foundation

@Reducer
public struct AppDelegate {
    @Dependency(\.backgroundTaskClient) var backgroundTaskClient
    @Shared(.appStorage("backgroundFeedUpdateAllowed")) var backgroundFeedUpdateAllowed = false

    public init() {}

    public struct State {
        public init() {}
    }

    public enum Action {
        case didFinishLaunching
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .didFinishLaunching:
                return .concatenate(
                    handleBackgroundTask(),
                    scheduleBackgroundFeedRefreshTask()
                )
            }
        }
    }

    private func scheduleBackgroundFeedRefreshTask() -> EffectOf<Self> {
        guard backgroundFeedUpdateAllowed else {
            return .none
        }
        let beginDate = Date(timeIntervalSinceNow: 30 * 30)
        do {
            try backgroundTaskClient.schedule(id: BGTaskIdentifiers.feedRefresh.rawValue, beginDate: beginDate)
        } catch {
            print("Failed to schedule background refresh task: \(error.localizedDescription)")
        }
        return .none
    }

    private func handleBackgroundTask() -> EffectOf<Self> {
        backgroundTaskClient.handleBackgroundTask(id: BGTaskIdentifiers.feedRefresh.rawValue) { task in
            // TODO: implement background task handler
            task.setTaskCompleted(success: true)
        }
        return .none
    }
}
