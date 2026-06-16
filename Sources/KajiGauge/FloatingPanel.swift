import AppKit
import SwiftUI

// MARK: - DraggablePanel
//
// An always-on-top, borderless HUD panel that the user can drag anywhere on
// the desktop. .nonactivatingPanel so clicking it never steals focus from the
// frontmost app; .floating level so it stays above normal windows.
//
// Borderless NSPanels default to a ~3pt edge hit zone for resizing — the user
// has to park the cursor right on the edge. We widen this to 10pt by
// installing eight invisible `ResizeHandle` views (one per edge + corner)
// that own the resize gesture + cursor and sit ABOVE the SwiftUI host so they
// get first crack at mouse events.
final class DraggablePanel: NSPanel {
    /// Edge width for the resize hit zone. 10pt ≈ a comfortable grab target
    /// without leaking too far into the content. Corners count from both
    /// adjacent edges (so the union is the L-shaped corner region).
    private static let edgeWidth: CGFloat = 10

    init(content: NSView) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 200),
            // No .hudWindow — its material forces a dark vibrancy that fights the
            // light "Kaji Sun" theme. We paint our own warm gradient instead.
            // .resizable so we can also drag the edges/corners via the
            // ResizeHandle subviews; we paint our own shadow (no native chrome).
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

        // Install the eight resize handles. The hosting view is also added so
        // the SwiftUI content still draws (these handles are transparent).
        if let host = contentView {
            host.wantsLayer = true
            host.layer?.backgroundColor = .clear
            installResizeHandles(on: host)
        }
    }

    // Borderless windows can't become key by default; allow it so SwiftUI
    // interaction works without forcing app activation.
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    private func installResizeHandles(on host: NSView) {
        let w = DraggablePanel.edgeWidth
        // Corners first (drawn last so they sit on top of the edge handles
        // and own the cursor at the intersection). Each corner is square of
        // side `w`; edges are thin strips.
        let corners: [(ResizeHandle.Kind, CGRect)] = [
            (.topLeft,     CGRect(x: 0, y: host.bounds.maxY - w,
                                  width: w, height: w)),
            (.topRight,    CGRect(x: host.bounds.maxX - w, y: host.bounds.maxY - w,
                                  width: w, height: w)),
            (.bottomLeft,  CGRect(x: 0, y: 0, width: w, height: w)),
            (.bottomRight, CGRect(x: host.bounds.maxX - w, y: 0,
                                  width: w, height: w)),
        ]
        let edges: [(ResizeHandle.Kind, CGRect)] = [
            (.top,    CGRect(x: w, y: host.bounds.maxY - w,
                             width: max(0, host.bounds.width - 2 * w), height: w)),
            (.bottom, CGRect(x: w, y: 0,
                             width: max(0, host.bounds.width - 2 * w), height: w)),
            (.left,   CGRect(x: 0, y: w, width: w,
                             height: max(0, host.bounds.height - 2 * w))),
            (.right,  CGRect(x: host.bounds.maxX - w, y: w, width: w,
                             height: max(0, host.bounds.height - 2 * w))),
        ]
        for (kind, rect) in edges + corners {
            let handle = ResizeHandle(kind: kind, panel: self)
            handle.frame = rect
            handle.autoresizingMask = autoresizeMask(for: kind, in: host)
            host.addSubview(handle)
        }
    }

    private func autoresizeMask(for kind: ResizeHandle.Kind,
                                in host: NSView) -> NSView.AutoresizingMask {
        // Edges/corners move with their adjacent sides when the panel resizes.
        switch kind {
        case .topLeft:     return [.maxXMargin, .minYMargin]
        case .topRight:    return [.minXMargin, .minYMargin]
        case .bottomLeft:  return [.maxXMargin, .maxYMargin]
        case .bottomRight: return [.minXMargin, .maxYMargin]
        case .top:         return [.width, .minYMargin]
        case .bottom:      return [.width, .maxYMargin]
        case .left:        return [.maxXMargin, .height]
        case .right:       return [.minXMargin, .height]
        }
    }
}

// MARK: - ResizeHandle
//
// An invisible NSView that owns one of the eight panel edges/corners. It
// overrides `mouseDown` to start a resize, tracks the delta in
// `mouseDragged`, and switches the cursor when the mouse enters/leaves.
final class ResizeHandle: NSView {
    enum Kind {
        case topLeft, topRight, bottomLeft, bottomRight
        case top, bottom, left, right
    }
    private let kind: Kind
    private weak var panel: NSPanel?
    private var startOrigin: NSPoint = .zero
    private var startSize: NSSize = .zero
    private var startFrame: NSRect = .zero

    init(kind: Kind, panel: NSPanel) {
        self.kind = kind
        self.panel = panel
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) { fatalError() }

    override var acceptsFirstResponder: Bool { true }
    override func hitTest(_ point: NSPoint) -> NSView? {
        // Block any hits in our rect so the SwiftUI host doesn't steal them.
        // We still let the panel's own isMovableByWindowBackground handle the
        // background drag (we only sit on the edges).
        bounds.contains(point) ? self : nil
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: cursor())
    }

    override func mouseDown(with event: NSEvent) {
        guard let panel = panel else { return }
        startFrame = panel.frame
        startOrigin = startFrame.origin
        startSize = startFrame.size
        window?.makeFirstResponder(self)
    }

    override func mouseDragged(with event: NSEvent) {
        guard let panel = panel else { return }
        // Location in window coords; convert to delta in screen coords (Y up).
        let loc = event.locationInWindow
        let start = window?.mouseLocationOutsideOfEventStream ?? loc
        let dx = loc.x - start.x
        let dy = loc.y - start.y
        apply(dx: dx, dy: dy, to: panel)
    }

    private func apply(dx: CGFloat, dy: CGFloat, to panel: NSPanel) {
        var origin = startOrigin
        var size = startSize
        // NSPanel resize: edges/corners modify origin + size according to which
        // side the user grabbed. Y is screen-up here (dy > 0 = drag up).
        switch kind {
        case .topLeft:
            origin.x += dx; origin.y += dy
            size.width -= dx; size.height += dy
        case .topRight:
            origin.y += dy
            size.width += dx; size.height += dy
        case .bottomLeft:
            origin.x += dx
            size.width -= dx; size.height -= dy
        case .bottomRight:
            size.width += dx; size.height -= dy
        case .top:
            origin.y += dy
            size.height += dy
        case .bottom:
            size.height -= dy
        case .left:
            origin.x += dx
            size.width -= dx
        case .right:
            size.width += dx
        }
        // Clamp to the same bounds the panel's minSize / maxSize enforce.
        let minS = panel.minSize, maxS = panel.maxSize
        size.width = min(max(size.width, minS.width),  maxS.width)
        size.height = min(max(size.height, minS.height), maxS.height)
        // Re-derive origin for the clamped size so the grabbed edge stays
        // anchored to the cursor (only the non-anchored corners move).
        switch kind {
        case .topLeft:
            origin.x = startOrigin.x + (startSize.width - size.width)
            origin.y = startOrigin.y + (startSize.height - size.height)
        case .topRight:
            origin.y = startOrigin.y + (startSize.height - size.height)
        case .bottomLeft:
            origin.x = startOrigin.x + (startSize.width - size.width)
        case .top:
            origin.y = startOrigin.y + (startSize.height - size.height)
        case .left:
            origin.x = startOrigin.x + (startSize.width - size.width)
        default: break
        }
        panel.setFrame(NSRect(origin: origin, size: size), display: true)
    }

    private func cursor() -> NSCursor {
        switch kind {
        case .topLeft, .bottomRight: return .crosshair
        case .topRight, .bottomLeft: return .crosshair
        case .top, .bottom:          return .resizeUpDown
        case .left, .right:          return .resizeLeftRight
        }
    }
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
