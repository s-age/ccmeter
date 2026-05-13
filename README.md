# CCMeter

A macOS menu bar app that displays your [Claude Code](https://docs.anthropic.com/en/docs/claude-code) usage at a glance.

<p align="center">
  <img src="docs/menubar.png" alt="Menu bar showing usage percentages with a donut chart" />
  &emsp;
  <img src="docs/popover.png" alt="Popover showing detailed usage breakdown" width="320" />
</p>

## Features

- **Menu bar donut chart** -- shows 5-hour session and 7-day weekly utilization as nested rings
- **Detailed popover** -- 5-Hour Session, 7-Day Weekly, and 7-Day Sonnet rate limits with progress bars and reset times
- **Auto-refresh** -- configurable polling interval (1 / 3 / 5 / 10 / 15 / 30 / 60 min)
- **Launch at Login** -- optional auto-start on macOS boot

## Requirements

- macOS 14.0 (Sonoma) or later
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and signed in

## Keychain Access

CCMeter reads the OAuth credentials that Claude Code stores in the macOS Keychain (service: `Claude Code-credentials`). On first launch, macOS will prompt you to allow Keychain access -- this is required for the app to authenticate with the Anthropic API and fetch your usage data.

The app never performs its own OAuth login flow. It only reads the tokens that Claude Code has already saved, and refreshes them automatically when they expire.

## Installation

### Build from source

Xcode (or the Xcode Command Line Tools with Swift 5.9+) is required.

```sh
git clone https://github.com/anthropics/ccmeter.git   # adjust URL as needed
cd ccmeter
./Scripts/build.sh --install
```

This builds a release binary, assembles `CCMeter.app`, code-signs it, and copies it to `/Applications`.

#### Build options

| Flag | Description |
|------|-------------|
| `--clean` | Clean build artifacts before building |
| `--test` | Run tests before building |
| `--install` | Install to `/Applications` after building |
| `--skip-icon` | Skip app icon generation |
| `--no-sign` | Skip code signing |

## License

MIT
