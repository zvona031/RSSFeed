import Dependencies
import DependenciesMacros
import UserNotifications

@DependencyClient
public struct UserNotificationClient: Sendable {
  public var add: @Sendable (UNNotificationRequest) async throws -> Void
  public var getNotificationSettings: @Sendable () async -> UNAuthorizationStatus = {
      .notDetermined
  }
  public var requestAuthorization: @Sendable (UNAuthorizationOptions) async throws -> Bool
}

extension UserNotificationClient: DependencyKey {
    public static let liveValue = Self {
        try await UNUserNotificationCenter.current().add($0)
    } getNotificationSettings: {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
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
