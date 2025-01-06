import ComposableArchitecture
import FeedsFeature
import Foundation
import BackgroundTasks
import Clients

@Reducer
public struct AppDelegate {
    @Dependency(\.userNotificationClient) var userNotifications
    public init() {}

    public struct State {
        var backgroundFeedRefresh: BackgroundFeedRefreshFeature.State
        
        public init(backgroundFeedRefresh: BackgroundFeedRefreshFeature.State) {
            self.backgroundFeedRefresh = backgroundFeedRefresh
        }
    }

    public enum Action {
        case didFinishLaunching
        case userNotifications(UserNotificationClient.DelegateEvent)
        case backgroundFeedRefresh(BackgroundFeedRefreshFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.backgroundFeedRefresh, action: \.backgroundFeedRefresh) {
            BackgroundFeedRefreshFeature()
        }

        Reduce<State, Action> { _, action in
            switch action {
            case .didFinishLaunching:
                let userNotificationsEventStream = self.userNotifications.delegate()
                return .run { send in
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask {
                          for await event in userNotificationsEventStream {
                            await send(.userNotifications(event))
                          }
                        }

                        group.addTask {
                            await send(.backgroundFeedRefresh(.observeFeatureEnabled))
                        }
                    }
                }
            case .backgroundFeedRefresh:
                return .none

            case .userNotifications(.willPresentNotification(let completionHandler)):
                completionHandler([.list, .banner, .sound])
                return .none

            case .userNotifications:
              return .none
            }
        }
    }
}
