<div align="center">

# Kaji

**A beautiful macOS menu-bar app for your AI usage.**
读本地、不联网，把 Claude · Codex · MiniMax · Ark Agent 的额度，安静地住进你的菜单栏。

<a href="https://github.com/interesting-vibe-coding/kaji-gauge/releases/latest"><img src="https://img.shields.io/github/v/release/interesting-vibe-coding/kaji-gauge?color=F25C05&label=release&labelColor=211C15" alt="latest release"></a>
<img src="https://img.shields.io/badge/macOS-13%2B%20%C2%B7%20Apple%20Silicon-F25C05?labelColor=211C15" alt="macOS 13+, Apple Silicon">
<a href="LICENSE"><img src="https://img.shields.io/github/license/interesting-vibe-coding/kaji-gauge?color=F25C05&labelColor=211C15" alt="MIT license"></a>

<img src="docs/hero.png" width="820" alt="Kaji — menu-bar rings and a compact quota popover">

</div>

## Install · 安装

```sh
curl -fsSL https://raw.githubusercontent.com/interesting-vibe-coding/kaji-gauge/main/install.sh | bash
```

一行装好 —— 拖进 `/Applications`、启动，菜单栏就出现额度环。需要 macOS 13+、Apple Silicon。
缺 `python3` 时安装脚本会自动帮你装 Xcode 命令行工具（已装则跳过）。

应用暂时**未签名**：安装脚本会替你清掉 Gatekeeper 隔离标记 —— 让你知道发生了什么，而不是假装没这回事。
等正式签名 + 公证后，这一步就消失了。

## What it shows · 它显示什么

每个服务一枚**双环 / double ring**：外环是 5 小时窗口，内环是 7 天窗口；中心是各家自己的标记
（Claude 星芒、Codex 结、MiniMax 的 M、Ark 菱形），大数字是 5 小时用量。7 天百分比写在标签里，
旁边直接写本地 reset 时间；逼近周上限时转为琥珀色。

- **四个信号 · Four signals** —— Claude、Codex、MiniMax 直接读你本地的 CLI 文件，无需 API key；
  Ark Agent 用本地 Volcengine 凭据。
- **一种形态 · One surface** —— 菜单栏环 (menu bar) + 点击展开的 quota popover。没有悬浮窗，没有可拖动 dock。
- **两种风格 · Mono / Color**（设置 → 菜单栏）—— Mono 默认，与原生图标一同安静；Color 用 Kaji 柿橙。
- **点一下展开 popover** —— 5h 倒计时、7d 本地 reset 时间、按服务显隐、S/M/L 尺寸、已用 / 剩余切换、
  EN / 中文。右键图标是同样的菜单。
- **自动日夜 · Auto light/dark** —— 白天 *Kaji Sun*，夜里 *Kaji Ember*。

一切由内置、零依赖的 Python reader 在本地读取。**Nothing leaves your machine.**

## Updates · 更新

启动时检查一次 GitHub Releases（最多几小时一次）。有新版就在菜单栏图标上点一个小圆点，
右键菜单出现 **Update to vX**，点开发布页。只碰公开 GitHub API，不上传任何东西。

## Build from source

```sh
swift run                 # dev — menu-bar agent, no dock icon
./scripts/build-app.sh    # release bundle → dist/KajiGauge.app
```

CLT-only 机器上 SwiftPM 链接不动时，用 `./scripts/build-local.sh`（直接 `swiftc`，编译并装到 `/Applications`）。

## Part of Kaji

Kaji 是舵，也是状态层：quota、reset time、provider health，先做轻，再接 pet/status bridge。
还有一个小[主页](https://interesting-vibe-coding.github.io/kaji-gauge-site/)。

## License

MIT — see [LICENSE](LICENSE).
