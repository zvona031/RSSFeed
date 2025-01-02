import SwiftUI

public struct RoundedShadowModifier: ViewModifier {

    public init() {}

    public func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

public extension View {
    func roundedShadow() -> some View {
        modifier(RoundedShadowModifier())
    }
}
