# Kaji Gauge

Your AI-provider quota, at a glance — warm ring gauges for **Claude**, **Codex**,
**MiniMax** and **Ark**, in your menu bar and on your desktop.

<p align="center">
  <a href="https://github.com/interesting-vibe-coding/kaji-gauge/releases/latest"><img src="https://img.shields.io/github/v/release/interesting-vibe-coding/kaji-gauge?color=F25C05&label=release&labelColor=211C15" alt="latest release"></a>
  <img src="https://img.shields.io/badge/macOS-13%2B%20%C2%B7%20Apple%20Silicon-F25C05?labelColor=211C15" alt="macOS 13+, Apple Silicon">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/interesting-vibe-coding/kaji-gauge?color=F25C05&labelColor=211C15" alt="MIT license"></a>
</p>

<p align="center">
  <img src="docs/gauge-light.png" width="320" alt="Kaji Sun — light">
  &nbsp;&nbsp;
  <img src="docs/gauge-dark.png" width="320" alt="Kaji Ember — dark">
</p>

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/interesting-vibe-coding/kaji-gauge/main/install.sh | bash
```

Drops the app in `/Applications` and launches it — the rings appear in your menu
bar. macOS 13+, Apple Silicon. Needs `python3` (ships with the Xcode command-line
tools) to read your usage.

The app is **unsigned** for now, so the installer clears the Gatekeeper
quarantine for you — worth knowing that's what's happening. Once the build is
signed and notarized, that step goes away.

## What it shows

<p align="center">
  <img src="docs/menubar-dark.png" height="24" alt="menu bar — mono dual rings">
  &nbsp;&nbsp;&nbsp;
  <img src="docs/menubar-color-dark.png" height="24" alt="menu bar — color dual rings">
</p>

One concentric **double ring** per provider: the **outer** arc is your 5-hour
window, the **inner** arc your 7-day window. In the center sits the provider's
own mark — the Claude burst, the Codex knot, the MiniMax *M*, the Ark diamond —
with the 5-hour percent as the big number. The 7-day percent rides in the label
below and turns amber as the weekly limit nears.

- **Four providers** — Claude, Codex and MiniMax read straight from your own CLI
  files with no API keys; Ark (both Agent and Coding plans) uses your local
  Volcengine credentials.
- **Two looks, your choice** (Settings → *Menu bar*) — **Mono** (default) draws
  the rings in the adaptive label color, to sit quietly among the native
  monochrome icons; **Color** draws the arcs in Kaji persimmon. Left pair above
  is Mono, right is Color.
- **Click** the rings for the full popover — both reset countdowns (5h and 7d),
  a draggable desktop panel you can float anywhere, per-provider show/hide, S/M/L
  size, a **Used / Remaining** toggle, the menu-bar style switch, and an
  **EN / 中文** toggle. Right-click the icon for the same options.
- **Auto light/dark** — *Kaji Sun* by day, *Kaji Ember* by night.

Everything is read locally by a bundled, dependency-free Python reader from your
own Claude Code / Codex / MiniMax / Ark files. Nothing leaves your machine.

## Updates

Kaji Gauge checks for a newer version on launch (and only that — once every few
hours at most). When one is out, a small dot rides the menu-bar glyph and an
**Update to vX** item appears in the right-click menu, opening the release page.
The check touches only the public GitHub API; nothing is sent.

## Build from source

```sh
swift run                 # dev — menu-bar agent, no dock icon
./scripts/build-app.sh    # release bundle → dist/KajiGauge.app
```

On a Command-Line-Tools-only machine where SwiftPM can't link, use
`./scripts/build-local.sh` (direct `swiftc`, builds + installs to `/Applications`).

## Part of Kaji

Kaji Gauge is the menu-bar companion to **[Kaji](https://github.com/interesting-vibe-coding/kaji)** —
a macOS-native terminal built for AI-assisted work. The rings, the warm palette,
and the 舵 helm mark all come from there: persimmon `#F25C05` by day, ember gold
by night. There's also a small
[landing page](https://interesting-vibe-coding.github.io/kaji-gauge-site/).

## License

MIT — see [LICENSE](LICENSE).
