import Sharing

extension SharedReaderKey where Self == AppStorageKey<Bool> {
  public static var newFeedItemsNotification: Self {
    appStorage("newFeedItemsNotification")
  }
}
