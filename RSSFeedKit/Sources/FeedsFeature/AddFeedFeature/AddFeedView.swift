import ComposableArchitecture
import SwiftUI

@ViewAction(for: AddFeedFeature.self)
public struct AddFeedView: View {
    @Perception.Bindable public var store: StoreOf<AddFeedFeature>

    public var body: some View {
        WithPerceptionTracking {
            TextField("RSS Feed URL", text: $store.rawUrl)
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
            
        }
    }
}
