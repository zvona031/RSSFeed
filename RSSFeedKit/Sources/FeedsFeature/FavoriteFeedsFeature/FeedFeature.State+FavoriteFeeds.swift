import ComposableArchitecture
import Foundation

extension IdentifiedArrayOf<FeedFeature.State> {
    public var favoriteFeeds: IdentifiedArrayOf<FeedFeature.State> {
        get { self.filter { $0.isFavorite } }
        set {
            var oldFavoriteFeeds = favoriteFeeds
            let newFavoriteFeeds = newValue

            if oldFavoriteFeeds.count != newFavoriteFeeds.count {
                // element deleted
                for element in newFavoriteFeeds {
                    oldFavoriteFeeds.remove(id: element.id)
                }
                guard let deletedElement = oldFavoriteFeeds.first else {
                    return
                }
                // removing element from the parent array as well
                self.remove(deletedElement)
            } else {
                // element modified
                for element in newFavoriteFeeds {
                    self[id: element.id] = element
                }
            }
        }
    }
}
