import AppKit

// Entry point. We use an explicit NSApplication setup rather than the SwiftUI
// `App` lifecycle so the app behaves as a pure menubar agent: the dock icon is
// suppressed via LSUIElement in Info.plist, and for `swift run` (no bundle /
// no Info.plist) we also set the activation policy to .accessory at runtime so
// the dev build doesn't show a dock icon either.
let app = NSApplication.shared
// main.swift top-level runs on the main thread but is nonisolated to the type
// system; AppDelegate is @MainActor, so assume isolation to build it here.
let delegate = MainActor.assumeIsolated { AppDelegate() }
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
