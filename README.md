# MISO - Method Input Switch Overlay

A lightweight macOS menu bar utility that provides a floating HUD overlay for quick input method switching.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.7+-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **🚀 Zero Permissions Required** - Core functionality works immediately without setup
- **🎯 HUD-Style Overlay** - Beautiful floating interface for quick switching
- **⚡ Native Performance** - Built with AppKit + SwiftUI for optimal speed
- **🎨 Customizable** - Configure which input methods to display
- **📱 Menu Bar Integration** - Lives quietly in your menu bar
- **💾 Position Memory** - Remembers overlay position across launches
- **🔄 Auto-Detection** - Automatically discovers system input methods

## Screenshots

*Coming soon - screenshots of the overlay and preferences interface*

## Installation

### Requirements

- macOS 12.0 (Monterey) or later
- No additional permissions required for core functionality

### Download

1. Download the latest release from [Releases](../../releases)
2. Unzip and drag MISO.app to your Applications folder
3. Launch MISO - it will appear in your menu bar

### Build from Source

```bash
git clone https://github.com/yourusername/miso.git
cd miso
open Miso.xcodeproj
```

Build and run in Xcode 14.0 or later.

## Usage

### Quick Start

1. **Launch MISO** - Look for the 🌐 icon in your menu bar
2. **Configure Methods** - Click the menu bar icon → "Preferences..." to set up input methods
3. **Use Overlay** - Click "Show/Hide Overlay" to toggle the floating HUD

### Overlay Controls

- **Click input method** to switch immediately  
- **Drag overlay** to reposition anywhere on screen
- Position is automatically saved

### Configuration

Open Preferences to:
- **Refresh from system** to detect new input methods
- **Open Input Sources Settings** to configure system input methods
- **Toggle launch at login** (macOS 13+)

## How It Works

MISO uses macOS's built-in Text Input Source APIs, which require no special permissions:

- `TISCopyCurrentKeyboardInputSource()` - Detect current input method
- `TISSelectInputSource()` - Switch between input methods
- `TISCreateInputSourceList()` - Discover available methods

This makes MISO a **zero-permission** utility that works immediately after installation.

## Architecture

Built with modern Swift patterns:

- **MVVM Architecture** - Clean separation of concerns
- **Protocol-Oriented Design** - Testable and maintainable code
- **SwiftUI + AppKit Hybrid** - Best of both frameworks
- **Reactive UI** - Real-time updates with Combine

See [CLAUDE.md](CLAUDE.md) for detailed technical documentation.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Clone the repository
2. Open `Miso.xcodeproj` in Xcode 14.0+
3. Build and run

### Code Style

- Follow Swift naming conventions
- Use MVVM pattern for new features
- Add protocol interfaces for services
- Write unit tests for business logic


## License

MIT License - see [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](../../issues)
- **Discussions**: [GitHub Discussions](../../discussions)

---

Made with ❤️ for the macOS community