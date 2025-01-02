import SwiftUI

public struct CircularProgressView: View {
    public init() {}

    public var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
    }
}
