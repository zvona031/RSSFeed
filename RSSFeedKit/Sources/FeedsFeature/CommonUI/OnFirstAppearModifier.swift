import SwiftUI

struct OnFirstAppearModifier: ViewModifier {
    private let onFirstAppearAction: () -> Void
    @State private var hasAppeared = false

    init(_ onFirstAppearAction: @escaping () -> Void) {
        self.onFirstAppearAction = onFirstAppearAction
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasAppeared else {
                    return
                }
                hasAppeared = true
                onFirstAppearAction()
            }
    }
}

extension View {
    func onFirstAppear(_ onFirstAppearAction: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearModifier(onFirstAppearAction))
    }
}
