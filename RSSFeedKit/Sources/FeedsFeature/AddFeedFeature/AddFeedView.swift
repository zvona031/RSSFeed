import ComposableArchitecture
import SwiftUI

@ViewAction(for: AddFeedFeature.self)
public struct AddFeedView: View {
    @Perception.Bindable public var store: StoreOf<AddFeedFeature>
    @FocusState private var focus: AddFeedFeature.Field?

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading) {
                RoundedTextField("RSS Feed URL", text: $store.rawUrl)
                    .focused($focus, equals: .url)
                    .keyboardType(.URL)

                if let errorMessage = store.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                }
            }
            .padding(.horizontal, 10)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        send(.addButtonTapped)
                    }
                    .disabled(store.addButtonDisabled)
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
