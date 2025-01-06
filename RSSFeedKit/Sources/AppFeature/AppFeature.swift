import ComposableArchitecture
import FeedsFeature
import SettingsFeature
import Foundation
import Clients
import Domain

@Reducer
public struct AppFeature {
    public init() {}

    @ObservableState
    public struct State {
        @Shared var feedItems: IdentifiedArrayOf<FeedFeature.State>
        var tab: Tab
        var appDelegate: AppDelegate.State
        var feeds: AllFeedsFeature.State
        var favoriteFeeds: FeedsListFeature.State
        var settings: SettingsFeature.State

        public init(
            tab: Tab = .feeds,
            feedItems: IdentifiedArrayOf<FeedFeature.State> = []
        ) {
            self.tab = tab
            let sharedFeedItems = Shared(value: feedItems)
            self._feedItems = sharedFeedItems
            self.feeds = AllFeedsFeature.State(feeds: sharedFeedItems)
            self.favoriteFeeds = FeedsListFeature.State(feeds: sharedFeedItems.favoriteFeeds)
            self.appDelegate = AppDelegate.State(backgroundFeedRefresh: BackgroundFeedRefreshFeature.State(feeds: sharedFeedItems))
            self.settings = SettingsFeature.State()
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case feeds(AllFeedsFeature.Action)
        case favoriteFeeds(FeedsListFeature.Action)
        case appDelegate(AppDelegate.Action)
        case settings(SettingsFeature.Action)
    }

    public var body: some ReducerOf<AppFeature> {
        BindingReducer()

        Scope(state: \.appDelegate, action: \.appDelegate) {
            AppDelegate()
        }

        Scope(state: \.feeds, action: \.feeds) {
            AllFeedsFeature()
        }

        Scope(state: \.favoriteFeeds, action: \.favoriteFeeds) {
            FeedsListFeature()
        }

        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }

        Reduce<State, Action> { state, action in
            switch action {
            case let .appDelegate(.userNotifications(.didReceiveResponse(response, completionHandler))):
                if let pushNotificationContent = decodePushNotificationContent(response.notification.request.content.userInfo) {
                    switch pushNotificationContent {
                    case .rssFeedItemUpdated(let rawUrl):
                        handleRssFeedItemsUpdatedNotification(state: &state, rawUrl: rawUrl)
                    }
                }
                completionHandler()
                return .none
            case .appDelegate:
                return .none
            case .binding:
                return .none
            case .feeds:
                return .none
            case .favoriteFeeds:
                return .none
            case .settings:
                return .none
            }
        }
    }

    private func handleRssFeedItemsUpdatedNotification(state: inout State, rawUrl: String) {
        guard let url = URL(string: rawUrl),
              let feedsList = state.feeds.viewState.feedList,
              let sharedFeedFeatureState = Shared(feedsList.$feeds[id: url].projectedValue),
              let rssFeed = sharedFeedFeatureState.wrappedValue.viewState.content
        else {
            return
        }

        state.tab = .feeds
        state.feeds.viewState.modify(\.feedList) { $0.destination = .details(FeedItemsListFeature.State(feed: rssFeed, isFavorite: sharedFeedFeatureState.isFavorite)) }
    }

    private func decodePushNotificationContent(_ userInfo: [AnyHashable: Any]) -> PushNotificationContent? {
        guard let data = try? JSONSerialization.data(withJSONObject: userInfo),
              let pushNotificationContent = try? JSONDecoder().decode(PushNotificationContent.self, from: data) else {
            return nil
        }
        return pushNotificationContent
    }
}

extension AppFeature {
    public enum Tab {
        case feeds
        case favorites
        case settings
    }
}
