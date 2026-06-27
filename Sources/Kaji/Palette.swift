import SwiftUI

// MARK: - KajiTheme (Auto: Kaji Graphite dark / Kaji Paper light)
//
// The two Kaji palettes as plain value types, selected by the SwiftUI
// `\.colorScheme` environment. Views read `@Environment(\.colorScheme)` and call
// `KajiTheme.resolve(scheme)` — so the whole gauge flips with macOS Auto/Light/
// Dark, deterministically (no NSColor dynamic-resolution quirks).
//
// Hexes are the product's ground truth:
//   - dark  "Kaji Graphite": graphite utility surfaces + restrained copper.
//   - light "Kaji Paper":    soft system paper + ink + muted copper.
// Copper is intentionally lower-saturation than the old bright persimmon.
struct KajiTheme {
    let bg: Color      // window / popover background (bottom of gradient)
    let bgTop: Color   // top of the warm background gradient
    let panel: Color   // cards / floating panel
    let cream: Color   // primary text / big number (ink on Sun)
    let mute: Color    // captions / secondary text
    let ash: Color     // faint / disabled
    let track: Color   // ring background track
    let gold: Color    // normal ring value arc
    let amber: Color   // near-limit (>=80%): deeper copper, same family
    let sun: Color     // Kaji brand copper — header dot

    static func resolve(_ scheme: ColorScheme) -> KajiTheme {
        scheme == .dark ? .dark : .light
    }

    static let dark = KajiTheme(
        bg:    Color(hex: 0x151514),
        bgTop: Color(hex: 0x1C1C1A),
        panel: Color(hex: 0x20201E),
        cream: Color(hex: 0xEDEAE4),
        mute:  Color(hex: 0x9B968D),
        ash:   Color(hex: 0x615D55),
        track: Color(hex: 0x35322D),
        gold:  Color(hex: 0xB98259),
        amber: Color(hex: 0xC66E42),
        sun:   Color(hex: 0xA76540)
    )

    static let light = KajiTheme(
        bg:    Color(hex: 0xF7F5F1),
        bgTop: Color(hex: 0xFCFBF8),
        panel: Color(hex: 0xFEFCF8),
        cream: Color(hex: 0x24231F), // ink
        mute:  Color(hex: 0x77736B),
        ash:   Color(hex: 0xB8B1A5),
        track: Color(hex: 0xE4DFD5),
        gold:  Color(hex: 0xA76540),
        amber: Color(hex: 0x8F4B2F),
        sun:   Color(hex: 0xA76540)
    )
}

// MARK: - Hex initializer
extension Color {
    /// Build a Color from a 0xRRGGBB integer (full opacity).
    init(hex: UInt32) {
        self.init(.sRGB,
                  red:   Double((hex >> 16) & 0xFF) / 255.0,
                  green: Double((hex >> 8) & 0xFF) / 255.0,
                  blue:  Double(hex & 0xFF) / 255.0,
                  opacity: 1.0)
    }
}
