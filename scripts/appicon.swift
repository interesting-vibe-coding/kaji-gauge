import SwiftUI
import AppKit

// Kaji app icon.
//
// Mono-first: a quiet K mark plus three small quota rings. This avoids the old
// orange helm/gauge metaphor and matches the product's default visual language.

private func hex(_ v: UInt32) -> Color {
    Color(.sRGB,
          red: Double((v >> 16) & 0xFF) / 255,
          green: Double((v >> 8) & 0xFF) / 255,
          blue: Double(v & 0xFF) / 255,
          opacity: 1)
}

struct AppIconView: View {
    private let size: CGFloat = 1024
    private let ink = hex(0x20201D)
    private let muted = hex(0x666660)
    private let track = hex(0xE7E7E2)
    private let edge = hex(0xDADAD6)
    private let paper = hex(0xF8F8F6)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 224, style: .continuous)
                .fill(
                    LinearGradient(colors: [hex(0xFFFFFF), paper],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 224, style: .continuous)
                        .stroke(edge, lineWidth: 4)
                )
                .shadow(color: .black.opacity(0.08), radius: 40, x: 0, y: 24)
                .padding(92)

            Text("K")
                .font(.system(size: 520, weight: .black, design: .rounded))
                .foregroundColor(ink)
                .offset(x: -128, y: -10)

            VStack(alignment: .leading, spacing: 24) {
                miniRing(progress: 0.78, line: 26, side: 128)
                miniRing(progress: 0.54, line: 23, side: 108)
                miniRing(progress: 0.32, line: 20, side: 88)
            }
            .offset(x: 246, y: 102)
        }
        .frame(width: size, height: size)
    }

    private func miniRing(progress: CGFloat, line: CGFloat, side: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(track, style: StrokeStyle(lineWidth: line, lineCap: .round))
            Circle()
                .trim(from: 0, to: progress)
                .stroke(muted, style: StrokeStyle(lineWidth: line, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .fill(ink)
                .frame(width: line * 0.72, height: line * 0.72)
        }
        .frame(width: side, height: side)
    }
}

@MainActor
func renderIcon(to path: String) {
    let renderer = ImageRenderer(content: AppIconView())
    renderer.scale = 1
    guard let img = renderer.nsImage,
          let tiff = img.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        print("render failed")
        return
    }
    try? png.write(to: URL(fileURLWithPath: path))
    print("wrote \(path) size=\(img.size)")
}

@main
struct IconMain {
    static func main() {
        MainActor.assumeIsolated {
            let out = CommandLine.arguments.dropFirst().first ?? "/tmp/kaji-icon-1024.png"
            renderIcon(to: out)
        }
    }
}
