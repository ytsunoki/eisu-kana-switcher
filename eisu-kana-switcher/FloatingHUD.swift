import AppKit
import SwiftUI

/// 切り替え時に画面中央へ一瞬「A」「あ」を表示する。
final class FloatingHUD {
    private var panel: NSPanel?
    private var hideWork: DispatchWorkItem?

    func show(_ text: String) {
        let panel = self.panel ?? makePanel()
        self.panel = panel
        panel.contentView = NSHostingView(rootView: HUDView(text: text))

        let size = NSSize(width: 120, height: 120)
        let screen = NSScreen.main?.visibleFrame ?? .zero
        panel.setFrame(NSRect(x: screen.midX - size.width / 2,
                              y: screen.midY - size.height / 2,
                              width: size.width, height: size.height), display: true)
        panel.alphaValue = 1
        panel.orderFrontRegardless()

        hideWork?.cancel()
        let work = DispatchWorkItem { [weak panel] in
            NSAnimationContext.runAnimationGroup({ $0.duration = 0.2; panel?.animator().alphaValue = 0 },
                                                 completionHandler: { panel?.orderOut(nil) })
        }
        hideWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: work)
    }

    private func makePanel() -> NSPanel {
        let p = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                        backing: .buffered, defer: true)
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = false
        p.level = .statusBar
        p.ignoresMouseEvents = true
        p.collectionBehavior = [.canJoinAllSpaces, .transient, .fullScreenAuxiliary]
        return p
    }
}

private struct HUDView: View {
    let text: String
    private let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)

    var body: some View {
        label
            .frame(width: 120, height: 120)
            .modifier(HUDBackground(shape: shape))
    }

    private var label: some View {
        Text(text).font(.system(size: 56, weight: .semibold))
    }
}

/// macOS 26 以降は Liquid Glass、それ以前は半透明の黒背景。
private struct HUDBackground: ViewModifier {
    let shape: RoundedRectangle

    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content
                .foregroundStyle(.primary)
                .glassEffect(.regular, in: shape)
        } else {
            content
                .foregroundStyle(.white)
                .background(shape.fill(.black.opacity(0.7)))
        }
    }
}
