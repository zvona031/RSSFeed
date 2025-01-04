import Dependencies
import DependenciesMacros
import Foundation
import BackgroundTasks

@DependencyClient
public struct BackgroundTaskClient: Sendable {
    public var schedule: @Sendable (_ id: String, _ beginDate: Date) throws -> Void
    public var handleBackgroundTask: @Sendable (_ id: String, @escaping (BGTask) -> Void) -> Void
}

extension BackgroundTaskClient: DependencyKey {
    public static let liveValue = BackgroundTaskClient { id, beginDate in
        let request = BGAppRefreshTaskRequest(identifier: id)
        request.earliestBeginDate = beginDate
        try BGTaskScheduler.shared.submit(request)
    } handleBackgroundTask: { id, action in
        BGTaskScheduler.shared.register(forTaskWithIdentifier: id, using: nil) { task in
            action(task)
        }
    }
}

extension DependencyValues {
    public var backgroundTaskClient: BackgroundTaskClient {
        get { self[BackgroundTaskClient.self] }
        set { self[BackgroundTaskClient.self] = newValue }
    }
}
