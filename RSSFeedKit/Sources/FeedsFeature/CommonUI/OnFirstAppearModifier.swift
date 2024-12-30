import SwiftUI

public struct OnFirstAppearModifier: ViewModifier {

    private let onFirstAppearAction: () -> Void
    @State private var hasAppeared = false

    public init(_ onFirstAppearAction: @escaping () -> Void) {
        self.onFirstAppearAction = onFirstAppearAction
    }

    public func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                onFirstAppearAction()
            }
    }
}

public extension View {
    func onFirstAppear(_ onFirstAppearAction: @escaping () -> Void) -> some View {
        return modifier(OnFirstAppearModifier(onFirstAppearAction))
    }
}
