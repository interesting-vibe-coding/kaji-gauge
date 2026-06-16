import AppKit
import SwiftUI

// MARK: - DraggablePanel
//
// An always-on-top, borderless HUD panel that the user can drag anywhere on
// the desktop. .nonactivatingPanel so clicking it never steals focus from the
// frontmost app; .floating level so it stays above normal windows.
final class DraggablePanel: NSPanel {
    init(content: NSView) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 200),
            // No .hudWindow — its material forces a dark vibrancy that fights the
            // light "Kaji Sun" theme. We paint our own warm gradient instead.
            // .resizable so the user can drag the edges/corners to scale the
            // HUD; we paint our own shadow (no native chrome).
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )
        isFloatingPanel = true
        level = .floating
        // Visible on every Space, even over fullscreen apps.
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        isMovableByWindowBackground = true   // drag from anywhere on the body
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        hidesOnDeactivate = false

        contentView = content
        // Size to fit the SwiftUI content.
        if let fitting = content.fittingSize as NSSize?, fitting.width > 0 {
            setContentSize(fitting)
        }

        // Allow the user to shrink toward the content's natural size and grow
        // comfortably up to ~3 rings at max ring size. Below the minimum the
        // SwiftUI content would clip; above the max, the rings stop scaling.
        let minW: CGFloat = 220
        let minH: CGFloat = 140
        let maxW: CGFloat = 720
        let maxH: CGFloat = 360
        minSize = NSSize(width: minW, height: minH)
        maxSize = NSSize(width: maxW, height: maxH)
        contentMinSize = NSSize(width: minW, height: minH)
        contentMaxSize = NSSize(width: maxW, height: maxH)
    }

    // Borderless windows can't become key by default; allow it so SwiftUI
    // interaction works without forcing app activation.
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

// MARK: - FloatingPanelController
//
// Owns the panel lifecycle and persists shown/hidden state in UserDefaults.
@MainActor
final class FloatingPanelController {
    private var panel: DraggablePanel?
    private let store: QuotaStore
    private let prefs: Prefs

    init(store: QuotaStore, prefs: Prefs) {
        self.store = store
        self.prefs = prefs
    }

    var isVisible: Bool {
        panel?.isVisible ?? false
    }

    /// Restore the last shown/hidden state on launch.
    func restore() {
        if UserDefaults.standard.bool(forKey: Config.kPanelVisible) {
            show()
        }
    }

    func toggle() {
        if isVisible { hide() } else { show() }
    }

    func show() {
        if panel == nil {
            // Resizable HUD: GaugeRowView runs in `expandToFill` mode so the
            // SwiftUI view tracks the panel's width and rings scale together.
            let root = GaugeRowView(store: store, prefs: prefs, expandToFill: true)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            let hosting = NSHostingView(rootView: root)
            hosting.layer?.cornerRadius = 14
            hosting.frame = NSRect(origin: .zero, size: hosting.fittingSize)
            // Track the panel's content size on resize (width + height), so
            // the SwiftUI view reflows instead of staying anchored top-left.
            hosting.autoresizingMask = [.width, .height]
            let p = DraggablePanel(content: hosting)
            // Place near the top-right of the main screen on first show.
            if let screen = NSScreen.main {
                let v = screen.visibleFrame
                let size = p.frame.size
                p.setFrameOrigin(NSPoint(x: v.maxX - size.width - 24,
                                         y: v.maxY - size.height - 24))
            }
            panel = p
        }
        panel?.orderFrontRegardless()
        UserDefaults.standard.set(true, forKey: Config.kPanelVisible)
    }

    func hide() {
        panel?.orderOut(nil)
        UserDefaults.standard.set(false, forKey: Config.kPanelVisible)
    }
}
