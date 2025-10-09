# TimeFill

> Private, simple countdowns that fill with time.

TimeFill is a privacy-first countdown tracker app for iOS that visualizes your important moments using a battery-style progress indicator with heatmap visualization. Watch time fill up beautifully as your events approach.

## Features

- **Battery-Style Progress**: Visual time-filling animation that shows progress like a charging battery
- **Heatmap Visualization**: Compact grid showing each day filled as time passes
- **100% Private & Offline**: All data stored locally on your device using SwiftData - no tracking, no cloud sync
- **Live Widgets**: Track important moments right from your home screen (Minimal & Modular styles)
- **Smart Notifications**: Flexible reminders - 1 month, 1 week, or 1 day before your events
- **Calendar Import**: Pull in birthdays, trips, and events from your iOS Calendar in seconds
- **Year & Month Overview**: See how much of the year or month has passed at a glance
- **Multiple Events**: Track unlimited countdowns for birthdays, trips, deadlines, and more
- **Customizable**: Choose from multiple color themes and icons for each event
- **Dark Mode**: Beautiful dark interface optimized for OLED displays

## Design Philosophy

TimeFill uses a battery-style metaphor where time gradually fills up a battery indicator as your event approaches. Each day is represented as a small box in a heatmap grid, creating a visual representation of time passing - beautiful, meaningful, and instantly understandable.

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
- **WidgetKit Integration**: Live home screen widgets with App Group data sharing
- **EventKit**: Calendar import functionality
- **UserNotifications**: Smart notification scheduling
- **Canvas-based Animation**: High-performance battery/heatmap rendering using SwiftUI Canvas

## Project Structure

```
TimeFill/
├── TimeFillApp.swift               # App entry point
├── ContentView.swift               # Main tab view
├── Models/
│   └── CountdownEvent.swift        # Event data model (SwiftData)
├── Views/
│   ├── LandingView.swift           # First-launch onboarding
│   ├── HomeView.swift              # Event list with battery cards
│   ├── AddEventView.swift          # Create new event
│   ├── DetailView.swift            # Event detail & countdown
│   ├── EventTimelineView.swift    # Chronological timeline
│   ├── SettingsView.swift          # App settings
│   ├── SandFillView.swift          # Battery/heatmap visualization
│   ├── CalendarImportView.swift    # Calendar integration
│   └── NotificationSettingsView.swift  # Notification preferences
├── Utils/
│   ├── ColorExtensions.swift       # Color themes & helpers
│   ├── NotificationManager.swift   # Notification scheduling
│   ├── WidgetDataManager.swift     # Widget data sharing
│   └── CalendarImporter.swift      # EventKit integration
└── TimeFillWidget/
    ├── TimeFillWidget.swift        # Widget entry point
    ├── MinimalCountdownView.swift  # Minimal widget style
    └── ModularCountdownView.swift  # Modular widget style
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Privacy

TimeFill is designed with privacy as a core principle:
- **100% Offline** - No network calls whatsoever
- **No Tracking** - Zero analytics, zero data collection
- **No Cloud Sync** - All data stays on your device
- **Local Storage** - SwiftData keeps everything private
- **No Third-Party SDKs** - Pure Swift/SwiftUI implementation

## Building

1. Open `TimeFill.xcodeproj` in Xcode
2. Select your development team in project settings
3. Build and run on simulator or device

## Customization

The app includes 9 color themes and multiple SF Symbol icon options for personalizing each event. All colors are carefully chosen to work beautifully with the battery/heatmap visualization.

## App Store

**Subtitle:** Private, simple countdowns that fill with time.

**Description:** TimeFill turns your milestones into calm, battery-style countdowns. Track birthdays, trips, launches—and watch your time fill up, day by day.

**Keywords:** countdown, timer, birthday, widget, tracker, progress, calendar, reminder, event, milestone

## License

© 2025 Olu A. All rights reserved.

Built with SwiftUI and ❤️

---

*TimeFill - Watch time fill beautifully*
