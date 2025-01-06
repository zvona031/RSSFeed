import SwiftUI

struct RoundedShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color("itemBackground", bundle: .module))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

extension View {
    func roundedShadow() -> some View {
        modifier(RoundedShadowModifier())
    }
}
