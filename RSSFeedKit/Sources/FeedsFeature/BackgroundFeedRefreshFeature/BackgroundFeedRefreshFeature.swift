import BackgroundTasks
import ComposableArchitecture
import Foundation

@Reducer
public struct BackgroundFeedRefreshFeature {
    @Dependency(\.feedsRefreshClient) var feedsRefreshClient
    @Dependency(\.backgroundTaskClient) var backgroundTaskClient

    public init() {}

    public struct State {
        @Shared(.appStorage("backgroundFeedUpdateAllowed")) var backgroundFeedUpdateAllowed = true
        @Shared var feeds: IdentifiedArrayOf<FeedFeature.State>
        var appRefreshTask: BGAppRefreshTask?

        public init(
            feeds: Shared<IdentifiedArrayOf<FeedFeature.State>>
        ) {
            self._feeds = feeds
        }
    }

    public enum Action {
        case scheduleTask
        case onTaskTriggered(BGTask)
        case onFeedsResponse([Result<RSSFeed, Error>])
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .scheduleTask:
                return scheduleBackgroundFeedRefreshTask(state: &state)
            case .onTaskTriggered(let task):
                guard let appRefreshTask = task as? BGAppRefreshTask,
                    !state.feeds.isEmpty
                else {
                    task.setTaskCompleted(success: true)
                    return .none
                }
                state.appRefreshTask = appRefreshTask
                return .run { [urls = state.feeds.map { $0.url }, feedsRefreshClient] send in
                    let results = await feedsRefreshClient.refreshFeeds(for: urls)
                    await send(.onFeedsResponse(results))
                }
            case let .onFeedsResponse(results):
                return handleFeedRefresh(state: &state, freshFeeds: results)
            }
        }
    }

    private func scheduleBackgroundFeedRefreshTask(state: inout State) -> EffectOf<Self> {
        guard state.backgroundFeedUpdateAllowed else {
            return .none
        }
        let beginDate = Date(timeIntervalSinceNow: 30 * 60)
        do {
            try backgroundTaskClient.schedule(id: BGTaskIdentifiers.feedRefresh.rawValue, beginDate: beginDate)
            print("Task scheduled successfully")
        } catch {
            print("Failed to schedule background refresh task: \(error.localizedDescription)")
        }
        return .none
    }

    private func handleFeedRefresh(state: inout State, freshFeeds: [Result<RSSFeed, Error>]) -> EffectOf<Self> {
        let successFeeds = freshFeeds.compactMap { try? $0.get() }
        for feed in successFeeds {
            guard let oldFeed = state.feeds[id: feed.id]?.viewState.content,
                  let newestOldItem = oldFeed.items.first,
                  let newestItem = feed.items.first,
                  newestItem.id != newestOldItem.id
            else {
                print("No new items found")
                continue
            }
            state.$feeds.withLock { feeds in
                feeds[id: feed.id]?.viewState.modify(\.content, yield: { $0 = feed })
            }
        }
        state.appRefreshTask?.setTaskCompleted(success: true)
        state.appRefreshTask = nil
        print("Background app refresh completed successfully")
        return .none
    }
}
