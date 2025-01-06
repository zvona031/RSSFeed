import ComposableArchitecture
@testable import FeedsFeature
import Foundation
import Testing

@MainActor
struct AllFeedsFeatureTests {
    @Test func test_onTask_success() async {
        let expectedResponse: [RSSFeedModel] = [
            RSSFeedModel(url: URL(string: "www.dummyUrl.hr")!, isFavorite: true)
        ]
        let testStore = TestStore(initialState: AllFeedsFeature.State(feeds: Shared(value: []))) {
            AllFeedsFeature()
        } withDependencies: {
            $0.rssFeedUrlsClient.get = {
                expectedResponse
            }
        }

        await testStore.send(\.view.onFirstAppear) {
            $0.$feeds.withLock {
                $0 = IdentifiedArray(uniqueElements: expectedResponse.map({ feedModel in
                    FeedFeature.State(url: feedModel.url, isFavorite: feedModel.isFavorite)
                }))
            }
        }

        await testStore.receive(\.feedStateUrlsResponse.success) {
            $0.viewState = .feedList(FeedsListFeature.State(feeds: $0.$feeds))
        }
    }

    @Test func test_onTask_failure() async {
        let expectedError = NSError(domain: "dummy", code: 0)
        let testStore = TestStore(initialState: AllFeedsFeature.State(feeds: Shared(value: []))) {
            AllFeedsFeature()
        } withDependencies: {
            $0.rssFeedUrlsClient.get = {
                throw expectedError
            }
        }

        await testStore.send(\.view.onFirstAppear)

        await testStore.receive(\.feedStateUrlsResponse.failure) {
            $0.viewState = .error
        }
    }

    @Test func test_onItemTapped() async {
        let testStore = TestStore(initialState: AllFeedsFeature.State(feeds: Shared(value: []))) {
            AllFeedsFeature()
        }

        await testStore.send(\.view.addButtonTapped) {
            $0.destination = .addFeed(AddFeedFeature.State())
        }
    }

    @Test func test_addItem_success() async {
        let rawUrl = "https://www.dummyUrl.com"
        let url = URL(string: rawUrl)!
        let testStore = TestStore(initialState: AllFeedsFeature.State(feeds: Shared(value: []), destination: .addFeed(AddFeedFeature.State(rawUrl: rawUrl)))) {
            AllFeedsFeature()
        }

        await testStore.send(\.destination.addFeed.view.addButtonTapped) {
            $0.destination?.modify(\.addFeed, yield: { $0.focus = nil })
        }

        await testStore.receive(\.destination.addFeed.delegate.rssFeedAdded, url) {
            $0.destination = nil
            $0.$feeds.withLock { $0.append(FeedFeature.State(url: url, isFavorite: false)) }
        }
    }
}
