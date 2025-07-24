# MISO - Method Input Switch Overlay

## Project Overview

MISO is a macOS menu bar utility that provides a floating overlay for quick input method switching. It allows users to switch between configured input methods using a HUD-style overlay that can be toggled via the menu bar or keyboard shortcuts.

## Architecture - MVVM Pattern

The application follows the Model-View-ViewModel (MVVM) architectural pattern with a clean separation of concerns.

### Directory Structure

```
Miso/
├── Models/
│   ├── InputMethod.swift         # Data model for input methods
│   └── WindowPosition.swift      # Data model for window positioning
├── Views/
│   ├── PreferencesView.swift     # Main settings/preferences view (SwiftUI)
│   └── OverlayView.swift         # AppKit overlay view for HUD (NSView with Core Graphics)
├── ViewModels/
│   ├── AppViewModel.swift        # App-level view model
│   ├── ContentViewModel.swift    # Settings view model
│   └── OverlayViewModel.swift    # Overlay view model
├── Services/
│   ├── InputMethodService.swift  # Input method system interaction
│   ├── PermissionService.swift   # Permission handling
│   ├── PreferencesService.swift  # User preferences storage
│   └── OverlayWindowService.swift # Window positioning logic
├── Controllers/
│   └── PreferencesWindowController.swift # AppKit window management
├── MisoApp.swift                 # App entry point (AppKit-based)
├── OverlayWindowController.swift # Overlay window management
├── LoginItemService.swift        # Launch at login functionality (macOS 13+)
├── Info.plist                    # App configuration (LSUIElement=true)
AND CLAUDE.md                     # This documentation file
```

### Component Responsibilities

#### Models
- **InputMethod**: Represents an input method with id, name, shortName, and flag
- **WindowPosition**: Stores x,y coordinates for window positioning

#### Views
- **PreferencesView**: Main settings/preferences UI using SwiftUI, observes ContentViewModel
- **OverlayView**: AppKit-based HUD overlay (NSView) with custom Core Graphics drawing and mouse handling

#### ViewModels
- **AppViewModel**: Manages app-level state and permissions
- **ContentViewModel**: Manages input method configuration, settings, and permission status
- **OverlayViewModel**: Manages overlay state and input method switching

#### Services (Protocol-Oriented)
- **InputMethodService**: Interfaces with macOS Text Input Source APIs
- **PermissionService**: Handles accessibility and input monitoring permissions
- **PreferencesService**: Manages UserDefaults storage
- **OverlayWindowService**: Manages window positioning logic

#### Controllers
- **PreferencesWindowController**: AppKit window controller that hosts SwiftUI PreferencesView
- **OverlayWindowController**: Manages the floating overlay window

## Key Features

### 1. Input Method Management (No Permissions Required)
- Automatic detection of system input methods using Text Input Source APIs
- User configuration of displayed methods
- Real-time switching between methods without special permissions
- Flag emoji and short name display
- Uses standard macOS Text Input Source framework

### 2. Permission Management
- Input monitoring permission for future keyboard shortcuts
- Guided permission setup with system alerts
- Direct integration with System Preferences
- Real-time status updates

### 3. Overlay Window
- Draggable HUD-style overlay
- Expandable/collapsible interface
- Custom Core Graphics drawing
- Position persistence

### 4. Menu Bar Integration
- UIElement app (hidden from dock by default)
- Status bar icon with menu
- Activation policy switching for preferences

## Technical Implementation

### Permission Architecture

MISO uses a streamlined permission model:

- **No Permissions Required**: Core input method switching uses macOS Text Input Source APIs
  - `TISCopyCurrentKeyboardInputSource()` - Get current input method
  - `TISSelectInputSource()` - Switch input methods
  - `TISCreateInputSourceList()` - List available methods
  - `TISGetInputSourceProperty()` - Get method properties

- **Optional Input Monitoring**: Only needed for future global keyboard shortcuts
  - Currently not used but available for enhancement
  - Uses IOKit HID Manager APIs

### App Lifecycle
- **Pure AppKit structure** with SwiftUI views
- Custom `@main` class instead of SwiftUI App/Scene
- Manual application lifecycle control
- Proper activation policy management

### Permission Handling
- HID manager for input monitoring permissions (for future keyboard shortcuts)
- Automatic addition to system preference lists
- Integrated alert system with System Preferences opening
- Core input method switching requires NO permissions

### Window Management
- AppKit window controllers for precise control
- SwiftUI views hosted in NSHostingView
- Position persistence across app launches
- Screen boundary validation

## Development Guidelines

### Code Style
- Protocol-oriented design for services
- Dependency injection for testability
- MVVM pattern adherence
- SwiftUI for UI, AppKit for system integration

### Testing Approach
- ViewModels and Services are unit testable
- Mock dependencies using protocols
- Separate UI logic from business logic

### Adding New Features

#### New Input Method Features
1. Add to `InputMethodService` protocol and implementation
2. Update `InputMethod` model if needed
3. Modify `OverlayViewModel` for new behavior
4. Update overlay drawing in `AppKitOverlayView`

#### New Permission Types
1. Add methods to `PermissionServiceProtocol`
2. Implement in `PermissionService`
3. Add UI to `ContentView`
4. Update `ContentViewModel` with new @Published properties

**Note**: Input method switching uses Text Input Source APIs and requires NO permissions

#### New Settings
1. Add to `PreferencesService` protocol
2. Update `ContentViewModel` with new properties
3. Add UI controls to `ContentView`
4. Ensure proper binding and persistence

### Build and Testing Commands

```bash
# Clean build
xcodebuild clean

# Build for testing
xcodebuild build -scheme Miso

# Archive for distribution
xcodebuild archive -scheme Miso
```

### Debug Information

#### Permission Issues
- Input monitoring only needed for keyboard shortcuts (not core functionality)
- Use `tccutil reset ListenEvent [bundle-id]` to reset input monitoring permissions
- Core input method switching works without any permissions

#### Overlay Issues
- Window positioning logged to console
- Check screen boundary validation
- Verify input method service responses

#### Performance
- Overlay drawing uses Core Graphics for efficiency
- Background thread for system API calls
- Minimal UI updates through reactive patterns

## Known Issues and Solutions

### 1. Input Monitoring Permission (Optional)
- Only needed for global keyboard shortcuts
- Core input method switching works without permissions
- Uses Text Input Source APIs which require no special access

### 2. Window Not Appearing from Xcode
- Xcode overrides LSUIElement setting during development
- Use `NSApp.setActivationPolicy(.accessory)` in code
- Normal behavior in distributed builds

### 3. Input Method Detection
- Some input methods may not be detected
- Check `TISInputSource` category and capabilities
- Ensure proper sorting and filtering

## Future Enhancements

### Potential Features
- Keyboard shortcut customization
- Theme customization for overlay
- Multiple overlay layouts
- Input method statistics
- Backup/restore configurations

### Architecture Improvements
- Coordinator pattern for navigation
- Reactive networking layer if needed
- Local database for complex configurations
- Plugin architecture for extensions

## Dependencies

- **macOS 12.0+** (minimum deployment target)
- **Xcode 14.0+** for development
- **Swift 5.7+**
- **SwiftUI** for UI components
- **AppKit** for system integration
- **Carbon Framework** for Text Input Source APIs (no permissions required)
- **IOKit** for input monitoring permissions (optional, for keyboard shortcuts)

## Distribution

### App Store Distribution
- No special entitlements required for core functionality
- Hardened runtime configuration
- App sandbox compatible (uses standard Text Input Source APIs)

### Direct Distribution
- Notarization required for Gatekeeper
- Code signing with Developer ID
- No sandbox restrictions

---

*This documentation is maintained to help future development and debugging of the MISO application.*