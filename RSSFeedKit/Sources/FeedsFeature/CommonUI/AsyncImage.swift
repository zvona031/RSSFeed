import Foundation
import SwiftUI
import Kingfisher

struct AsyncImage: View {
    let url: URL?
    @State var didFailToLoad = false

    var body: some View {
        if !didFailToLoad {
            KFImage(url)
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 60, height: 60)))
                .placeholder {
                    CircularProgressView()
                }
                .resizable()
                .onFailure({ _ in
                    didFailToLoad = true
                })
                .aspectRatio(contentMode: .fit)
        } else {
            Color.gray.opacity(0.6)
                .clipShape(.rect(cornerRadius: 4))
        }
    }

}
