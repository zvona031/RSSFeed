import BackgroundTasks
import ComposableArchitecture
import Foundation
import Clients
import UserNotifications
import Domain

@Reducer
public struct BackgroundFeedRefreshFeature {
    @Dependency(\.feedsRefreshClient) var feedsRefreshClient
    @Dependency(\.backgroundTaskClient) var backgroundTaskClient
    @Dependency(\.userNotificationClient) var userNotificationClient

    public init() {}

    public struct State {
        @Shared(.newFeedItemsNotification) var newFeedItemsNotificationEnabled = false
        @Shared var feeds: IdentifiedArrayOf<FeedFeature.State>
        var oldBackgroundFeedRefreshEnabled = false

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
        case onFeedsResponse([RSSFeed])
        case taskFinished
        case observeFeatureEnabled
        case featureEnabledChanged(Bool)
        case updateRSSFeed(RSSFeed)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .observeFeatureEnabled:
                return .publisher {
                    state.$newFeedItemsNotificationEnabled.publisher
                        .map(Action.featureEnabledChanged)
                }
            case .featureEnabledChanged(let enabled):
                guard state.oldBackgroundFeedRefreshEnabled != enabled else {
                    return .none
                }
                state.oldBackgroundFeedRefreshEnabled = enabled
                return featureAllowedChanged(state: state, enabled: enabled)
            case .taskFinished:
                state.appRefreshTask?.setTaskCompleted(success: true)
                state.appRefreshTask = nil
                return .run { send in
                    await send(.scheduleTask)
                }
            case .scheduleTask:
                return scheduleBackgroundFeedRefreshTask(state: state)
            case .onTaskTriggered(let task):
                return handleTaskTriggered(state: &state, task: task)
            case let .onFeedsResponse(results):
                return handleFeedRefresh(state: &state, freshFeeds: results)
            case .updateRSSFeed(let updatedFeed):
                return updateRssFeed(state: &state, updatedFeed: updatedFeed)
            }
        }
    }

    private func featureAllowedChanged(state: State, enabled: Bool) -> EffectOf<Self> {
        if enabled {
            return scheduleBackgroundFeedRefreshTask(state: state)
        } else {
            backgroundTaskClient.cancel(id: BGTaskIdentifiers.feedRefresh.rawValue)
            return .none
        }
    }

    private func scheduleBackgroundFeedRefreshTask(state: State) -> EffectOf<Self> {
        guard state.newFeedItemsNotificationEnabled else {
            return .none
        }
        let beginDate = Date(timeIntervalSinceNow: 30 * 60)
        do {
            try backgroundTaskClient.schedule(id: BGTaskIdentifiers.feedRefresh.rawValue, beginDate: beginDate)
        } catch {
            print("Failed to schedule background refresh task: \(error.localizedDescription)")
        }
        return .none
    }

    private func handleTaskTriggered(state: inout State, task: BGTask) -> EffectOf<Self> {
        guard let appRefreshTask = task as? BGAppRefreshTask,
            !state.feeds.isEmpty
        else {
            return .run { send in
                await send(.taskFinished)
            }
        }
        state.appRefreshTask = appRefreshTask
        return .run { [urls = state.feeds.map { $0.url }, feedsRefreshClient] send in
            let results = await feedsRefreshClient.refreshFeeds(for: urls)
            await send(.onFeedsResponse(results))
        }
    }

    private func handleFeedRefresh(state: inout State, freshFeeds: [RSSFeed]) -> EffectOf<Self> {
        .run { [oldFeeds = state.feeds] send in
            for feed in freshFeeds {
                guard let oldFeed = oldFeeds[id: feed.id]?.viewState.content,
                      let newestOldItem = oldFeed.items.first,
                      let newestItem = feed.items.first,
                      newestItem.id != newestOldItem.id
                else {
                    continue
                }

                await send(.updateRSSFeed(feed))
            }
            await send(.taskFinished)
        }
    }

    private func updateRssFeed(state: inout State, updatedFeed: RSSFeed) -> EffectOf<Self> {
        state.$feeds.withLock { feeds in
            feeds[id: updatedFeed.id]?.viewState.modify(\.content, yield: { $0 = updatedFeed })
        }
        return addNotification(state: state, rssFeed: updatedFeed)
    }

    private func addNotification(state: State, rssFeed: RSSFeed) -> EffectOf<Self> {
        guard state.newFeedItemsNotificationEnabled else {
            return .none
        }
        return .run { [userNotificationClient] _ in
            guard await userNotificationClient.getAuthorizationStatus() == .authorized
            else { return }
            let notificationContent: PushNotificationContent = .rssFeedItemUpdated(rssFeed.url.absoluteString)
            guard let userInfo = encodePushNotificationContent(notificationContent) else {
                return
            }
            let request = UNNotificationRequest(id: rssFeed.url.path(), feedName: rssFeed.name, userInfo: userInfo)
            do {
                try await userNotificationClient.add(request)
            } catch {
                print("Failed to schedule notifications: \(error.localizedDescription)")
            }
        }
    }

    private func encodePushNotificationContent(_ content: PushNotificationContent) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(content),
              let userInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        return userInfo
    }
}

extension UNNotificationRequest {
    fileprivate convenience init(id: String, feedName: String, userInfo: [String: Any]) {
        let content = UNMutableNotificationContent()
        content.title = "Fresh news"
        content.body = "Check out the latest news on \(feedName)"
        content.sound = .default
        content.userInfo = userInfo
        self.init(identifier: id, content: content, trigger: nil)
    }
}
