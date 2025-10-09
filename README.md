# TimeFill

> Watch your moments fill with time.

TimeFill is a privacy-first countdown tracker app for iOS that visualizes your important moments using a unique digital hourglass animation. Unlike traditional ring-based progress trackers, TimeFill uses a sand-fill metaphor where time gradually fills an hourglass as your event approaches.

## Features

- **Digital Hourglass Animation**: Beautiful sand-fill visualization that shows progress toward your events
- **100% Private**: All data stored locally on your device using SwiftData
- **Multiple Events**: Track unlimited countdowns for birthdays, trips, deadlines, and more
- **Customizable**: Choose from multiple color themes and icons for each event
- **Live Updates**: Real-time countdown with days, hours, minutes, and seconds
- **Export Data**: Export your events as JSON (local only, no cloud sync)
- **Dark Mode**: Beautiful dark interface optimized for OLED displays

## Design Philosophy

TimeFill replaces the circular ring progress style with an hourglass that fills from bottom to top as time passes. The sand particles create a calming, ambient animation that represents the flow of time.

**Color Palette:**
- Background Dark: `#101218`
- Background Light: `#F7F7F8`
- Primary Cyan (App Icon): `#36C2FF`
- Primary Gradient: `#36C2FF` → `#9B89FF`
- Completion Accent: `#F2C94C`

**Typography:** SF Pro Rounded (400-600 weight)

## Architecture

- **SwiftUI + SwiftData**: Modern declarative UI with local data persistence
- **No External Dependencies**: Pure Swift/SwiftUI implementation
- **Canvas-based Animation**: High-performance hourglass rendering using SwiftUI Canvas
- **TimelineView**: Smooth 60fps animation updates

## Project Structure

```
TimeFill/
├── TimeFillApp.swift          # App entry point
├── ContentView.swift          # Main tab view
├── Models/
│   └── CountdownEvent.swift   # Event data model
├── Views/
│   ├── SandFillView.swift     # Hourglass animation
│   ├── HomeView.swift         # Event list
│   ├── AddEventView.swift     # Create new event
│   ├── DetailView.swift       # Event detail & countdown
│   └── SettingsView.swift     # App settings
└── Utils/
    └── ColorExtensions.swift  # Color themes & helpers
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Privacy

TimeFill is designed with privacy as a core principle:
- No network calls
- No analytics or tracking
- No external APIs
- All data stored locally with SwiftData
- Optional local-only export to JSON

## Building

1. Open `TimeFill.xcodeproj` in Xcode
2. Select your development team in project settings
3. Build and run on simulator or device

## Customization

The app includes 9 color themes and 16 icon options for personalizing each event. All colors use soft, pastel tones that work well with the hourglass visualization.

## License

Created with Claude Code - A privacy-first countdown tracker

---

**Tagline:** "Set your moments. Watch them fill — grain by grain — until the day arrives."
