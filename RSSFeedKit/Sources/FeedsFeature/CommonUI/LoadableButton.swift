import SwiftUI

public struct LoadableButton: View {
    private let isRequestInFlight: Bool
    private let action: () -> Void

    public init(
        isRequestInFlight: Bool,
        action: @escaping () -> Void
    ) {
        self.isRequestInFlight = isRequestInFlight
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            if isRequestInFlight {
                CircularProgressView()
            } else {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
            }
        }
        .disabled(isRequestInFlight)
    }
}
