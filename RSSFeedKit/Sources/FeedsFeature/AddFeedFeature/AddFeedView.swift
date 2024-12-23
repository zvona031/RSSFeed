import ComposableArchitecture
import SwiftUI

@ViewAction(for: AddFeedFeature.self)
public struct AddFeedView: View {
    @Perception.Bindable public var store: StoreOf<AddFeedFeature>
    @FocusState private var focus: AddFeedFeature.Field?

    public var body: some View {
        WithPerceptionTracking {
            TextField("RSS Feed URL", text: $store.rawUrl)
                .focused($focus, equals: .url)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add") {
                            send(.addButtonTapped)
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            send(.cancelButtonTapped)
                        }
                    }
                }
                .bind($store.focus, to: $focus)
        }
    }
}
