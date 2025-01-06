import UserNotifications

extension UserNotificationClient {
    public enum DelegateEvent {
      case didReceiveResponse(UNNotificationResponse, completionHandler: @Sendable () -> Void)
      case willPresentNotification(completionHandler: @Sendable (UNNotificationPresentationOptions) -> Void)
    }
    
    class Delegate: NSObject, UNUserNotificationCenterDelegate {
      let continuation: AsyncStream<UserNotificationClient.DelegateEvent>.Continuation

      init(continuation: AsyncStream<UserNotificationClient.DelegateEvent>.Continuation) {
        self.continuation = continuation
      }

      func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
      ) {
        self.continuation.yield(
          .didReceiveResponse(response) { completionHandler() }
        )
      }

      func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
          @escaping (UNNotificationPresentationOptions) -> Void
      ) {
        self.continuation.yield(
          .willPresentNotification { completionHandler($0) }
        )
      }
    }
}
