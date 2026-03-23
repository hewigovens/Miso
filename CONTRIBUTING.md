# Contributing to Miso

## Requirements

- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later

## Development setup

```bash
git clone https://github.com/hewigovens/miso.git
cd miso
open Miso.xcodeproj
```

Build and run in Xcode.

## Architecture

- **MVVM** with protocol-oriented services
- **SwiftUI + AppKit hybrid** — SwiftUI for preferences, AppKit for overlay and system integration
- **Reactive UI** via Combine

See [CLAUDE.md](CLAUDE.md) for detailed technical documentation.

## Code style

- Follow standard Swift naming conventions
- Use the MVVM pattern for new features
- Add protocol interfaces for services
- Write unit tests for business logic
