import ComposableArchitecture
import SwiftUI

@ViewAction(for: FeedFeature.self)
public struct FeedView: View {
    public let store: StoreOf<FeedFeature>

    public init(
        store: StoreOf<FeedFeature>
    ) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            HStack {
                switch store.viewState {
                case .loading:
                    Text(store.url.absoluteString)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.leading, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(1)

                    CircularProgressView()

                case .error:
                    VStack {
                        Text(store.url.absoluteString)
                            .font(.subheadline)
                            .lineLimit(1)
                        Button("Retry") {
                            send(.retryButtonTapped)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .layoutPriority(1)

                case .content(let rssFeed):
                    VStack(alignment: .leading) {
                        ItemView(url: rssFeed.imageUrl, title: rssFeed.name, description: rssFeed.description)
                        Text("Last updated: \(rssFeed.lastUpdated.formatted(date: .abbreviated, time: .shortened))")
                            .font(.footnote)
                    }

                    LoadableButton(isRequestInFlight: store.isRequestInFlight) {
                        send(.refreshButtonTapped)
                    }
                }

                Button {
                    send(.favoriteButtonTapped)
                } label: {
                    Image(systemName: store.isFavorite ? "star.fill" : "star")
                        .frame(width: 24, height: 24)
                }
                Button {
                    send(.removeButtonTapped)
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 24, height: 24)
                }
            }
            .frame(height: 70)
            .padding(6)
            .roundedShadow()
            .onTapGesture {
                guard let rssFeed = store.viewState.content else {
                    return
                }
                send(.itemTapped(rssFeed))
            }
        }
    }
}
