# TimeFill - Setup Guide

## Quick Start

### 1. Open in Xcode
```bash
cd /Users/DunsinAgbolabori1/timefill/TimeFill
open TimeFill.xcodeproj
```

### 2. Configure Code Signing
1. Select the **TimeFill** project in the navigator
2. Select the **TimeFill** target
3. Go to **Signing & Capabilities** tab
4. Select your **Team** from the dropdown
5. Xcode will automatically generate a bundle identifier

### 3. Build & Run
- Select **iPhone 15 Pro** (or any simulator) from the scheme menu
- Press **Cmd+R** to build and run
- Or click the ▶️ Play button

## Key Files Overview

### Core App Files
- **TimeFillApp.swift** - App entry point with SwiftData container setup
- **ContentView.swift** - Main tab navigation (Overview / Settings)

### Data Layer
- **Models/CountdownEvent.swift** - SwiftData model for events
  - Stores: name, targetDate, colorHex, iconName
  - Computes: progress, daysRemaining, isCompleted, etc.

### Views
- **SandFillView.swift** - Custom hourglass animation using Canvas
  - Uses TimelineView for 60fps updates
  - Gradient fill animates from bottom to top
  - Particle effects for flowing sand

- **HomeView.swift** - Event list view
  - Empty state with onboarding message
  - Event cards with compact hourglasses
  - Real-time updates via Timer

- **AddEventView.swift** - Create new events
  - Name, date, color, icon pickers
  - 9 color themes, 16 icon options

- **DetailView.swift** - Event detail screen
  - Large hourglass visualization
  - Live countdown: days, hours, minutes, seconds
  - Edit & delete options

- **SettingsView.swift** - App settings
  - Auto-delete completed events toggle
  - Export data to JSON
  - About section

### Utilities
- **ColorExtensions.swift** - Color themes and hex conversion
  - 9 predefined pastel themes
  - Hex string to Color converter

## Features to Test

### 1. Creating Events
- Tap **+** in top-right corner
- Enter event name (e.g., "Birthday Party")
- Select future date
- Choose color and icon
- Tap **Save**

### 2. Viewing Progress
- Hourglass fills from bottom to top as time progresses
- Progress shown as percentage (0-100%)
- Real-time countdown updates every second

### 3. Editing Events
- Tap event card to open detail view
- Tap **⋯** menu → **Edit**
- Modify any field and save

### 4. Deleting Events
- Detail view → **⋯** menu → **Delete**
- Or swipe left on event card (if you add swipe gestures)

### 5. Settings
- Toggle auto-delete completed events
- Export all events to JSON file
- View app version and info

## Customization Tips

### Adding More Color Themes
Edit `ColorExtensions.swift`:
```swift
static let themes: [ColorTheme] = [
    // Add new theme:
    ColorTheme(hex: "#YOUR_HEX", name: "Your Color")
]
```

### Adding More Icons
Edit `AddEventView.swift` and `EditEventView.swift`:
```swift
private let icons = [
    // Add SF Symbol name:
    "your.icon.name"
]
```

### Adjusting Animation Speed
Edit `SandFillView.swift`:
```swift
// Change animation duration (default: 1.5 seconds)
.animation(.linear(duration: 2.0).repeatForever(autoreverses: false))
```

### Changing Background Colors
Edit `ColorExtensions.swift`:
```swift
static let timeFillDarkBg = Color(hex: "#YOUR_DARK_BG")
static let timeFillLightBg = Color(hex: "#YOUR_LIGHT_BG")
```

## Troubleshooting

### Build Errors
- **SwiftData not found**: Ensure deployment target is iOS 17.0+
- **Canvas errors**: Make sure using Xcode 15+
- **Preview crashes**: Try **Cmd+Option+P** to refresh previews

### Runtime Issues
- **No events showing**: Check SwiftData model container is properly configured
- **Animation not smooth**: Test on physical device (simulators can be slower)
- **Colors not showing**: Verify hex strings start with `#`

## Next Steps

### Enhancements to Consider
1. **Widget Support** - Show next event on home screen
2. **Notifications** - Alert when event is near
3. **Import Data** - JSON import to complement export
4. **iCloud Sync** - Optional cloud backup (still private)
5. **Haptic Feedback** - Add UIImpactFeedbackGenerator on completion
6. **Confetti Animation** - Celebrate completed events
7. **Categories** - Group events (Work, Personal, etc.)
8. **Recurring Events** - Birthdays, anniversaries
9. **Share Image** - Export hourglass as image

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [SF Symbols App](https://developer.apple.com/sf-symbols/) - Browse icons
- [Canvas API](https://developer.apple.com/documentation/swiftui/canvas)

---

Built with ❤️ using Claude Code
