import ComposableArchitecture
import Domain
import Kingfisher
import SwiftUI

@ViewAction(for: FeedFeature.self)
public struct FeedItemView: View {
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
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                case .error:
                    Button("Retry") {
                        send(.retryButtonTapped)
                    }
                    Spacer()
                case .content(let rssFeed):
                    KFImage(rssFeed.imageUrl)
                        .placeholder {
                            Color.gray.cornerRadius(5)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading) {
                        Text(rssFeed.name)
                            .font(.headline)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(.leading, 8)
                        if !rssFeed.description.isEmpty {
                            Text(rssFeed.description)
                                .font(.body)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.leading, 8)
                        }
                    }
                    
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
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .padding()
            .background(Color.white) // Background color for the item
            .cornerRadius(10) // Rounded corners
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Optional shadow
            .onTapGesture {
                guard let rssFeed = store.viewState.content else { return }
                send(.itemTapped(rssFeed))
            }
        }
    }
}
