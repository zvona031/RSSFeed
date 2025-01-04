import ComposableArchitecture
import FeedsFeature
import Foundation
import BackgroundTasks

@Reducer
public struct AppDelegate {
    public init() {}

    public struct State {
        var backgroundFeedRefresh: BackgroundFeedRefreshFeature.State
        
        public init(backgroundFeedRefresh: BackgroundFeedRefreshFeature.State) {
            self.backgroundFeedRefresh = backgroundFeedRefresh
        }
    }

    public enum Action {
        case didFinishLaunching
        case backgroundFeedRefresh(BackgroundFeedRefreshFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.backgroundFeedRefresh, action: \.backgroundFeedRefresh) {
            BackgroundFeedRefreshFeature()
        }

        Reduce<State, Action> { state, action in
            switch action {
            case .didFinishLaunching:
                return scheduleBackgroundFeedRefresh(state: &state)
            case .backgroundFeedRefresh:
                return .none
            }
        }
    }

    private func scheduleBackgroundFeedRefresh(state: inout State) -> EffectOf<Self> {
        BackgroundFeedRefreshFeature().reduce(into: &state.backgroundFeedRefresh, action: .scheduleTask)
            .map(Action.backgroundFeedRefresh)
    }
}
