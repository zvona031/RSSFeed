import ComposableArchitecture
import SwiftUI

@ViewAction(for: FeedFeature.self)
struct FeedView: View {
    let store: StoreOf<FeedFeature>

    var body: some View {
        WithPerceptionTracking {
            itemView()
                .task {
                    send(.onTask)
                }
        }
    }

    @ViewBuilder
    private func itemView() -> some View {
        HStack {
            switch store.viewState {
            case .loading:
                Text(store.url.absoluteString)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
            case .error:
                Button("Retry") {
                    send(.retryButtonTapped)
                }
                Spacer()
            case .content(let rssFeed):
                Text(rssFeed.name)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading, 8)
                Spacer()
                Button(action: {
                    send(.refreshButtonTapped)
                }) {
                    if store.isRequestInFlight {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                    }
                }
                .disabled(store.isRequestInFlight)
            }
            Button {
                send(.removeButtonTapped(store.id))
            } label: {
                Image(systemName: "trash")
                    .frame(width: 24, height: 24)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white) // Background color for the item
        .cornerRadius(10) // Rounded corners
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Optional shadow
    }
}
