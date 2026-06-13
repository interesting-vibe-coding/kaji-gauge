import SwiftUI

// MARK: - Kaji Ember palette (dark, warm)
//
// The product's signature warm-dark theme. A light "Sun" theme is a TODO;
// we ship Ember now. All colors are defined here as the single source of
// truth — never hardcode hex elsewhere.
enum Palette {
    static let bg     = Color(hex: 0x16100B) // deep warm black — window/popover background
    static let panel  = Color(hex: 0x1D160F) // slightly lighter — cards / floating panel
    static let cream  = Color(hex: 0xECE4D6) // primary text / big number
    static let mute   = Color(hex: 0x9C9283) // captions / secondary text
    static let ash    = Color(hex: 0x665E53) // disabled / faint
    static let track  = Color(hex: 0x3A3026) // ring background track
    static let sun    = Color(hex: 0xF25C05) // legacy brand SUN — NOT used in gauges (too harsh)
    static let amber  = Color(hex: 0xC87A2A) // near-limit (>=80%): same warm family, just deeper
    static let gold   = Color(hex: 0xD8A657) // normal ring value arc
}

// MARK: - Hex initializer
extension Color {
    /// Build a Color from a 0xRRGGBB integer. Always full opacity unless an
    /// alpha is supplied separately by the caller via `.opacity`.
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }
}
