import Dependencies
import DependenciesMacros
import UserNotifications
import CasePaths

@DependencyClient
public struct UserNotificationClient: Sendable {
  public var add: @Sendable (UNNotificationRequest) async throws -> Void
  public var getAuthorizationStatus: @Sendable () async -> UNAuthorizationStatus = { .notDetermined }
  public var delegate: @Sendable () -> AsyncStream<DelegateEvent> = { .finished }
  public var requestAuthorization: @Sendable (UNAuthorizationOptions) async throws -> Bool
}

extension UserNotificationClient: DependencyKey {
    public static let liveValue = Self {
        try await UNUserNotificationCenter.current().add($0)
    } getAuthorizationStatus: {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    } delegate: {
        AsyncStream { continuation in
            let delegate = Delegate(continuation: continuation)
            UNUserNotificationCenter.current().delegate = delegate
            continuation.onTermination = { _ in
                _ = delegate
            }
        }
    } requestAuthorization: {
        try await UNUserNotificationCenter.current().requestAuthorization(options: $0)
    }
}

extension DependencyValues {
    public var userNotificationClient: UserNotificationClient {
        get { self[UserNotificationClient.self] }
        set { self[UserNotificationClient.self] = newValue }
    }
}
