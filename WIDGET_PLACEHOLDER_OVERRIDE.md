# Widget Placeholder Override Documentation

## Problem
iOS widgets show gray system placeholder blocks when first added. We want to immediately display our custom dark "Select Event" instructional view instead.

## Solution Overview
Override the placeholder behavior at multiple levels in the widget system to ensure the custom SetupGuideView appears immediately.

---

## Changes Made

### 1. CountdownProvider.swift - Timeline Provider

#### placeholder(in:) Method
**OLD BEHAVIOR:** Returned sample event data
```swift
func placeholder(in context: Context) -> CountdownEntry {
    CountdownEntry(date: Date(), event: .sample)
}
```

**NEW BEHAVIOR:** Returns nil event to trigger custom guide
```swift
func placeholder(in context: Context) -> CountdownEntry {
    // OVERRIDE: Return nil event to trigger custom "Select Event" guide
    // instead of system gray blocks
    CountdownEntry(date: Date(), event: nil)
}
```

#### snapshot(for:in:) Method
**OLD BEHAVIOR:** Showed sample event when no data available
```swift
func snapshot(for configuration: SelectEventIntent, in context: Context) async -> CountdownEntry {
    if let event = await getEvent(for: configuration) {
        return CountdownEntry(date: Date(), event: event)
    } else {
        return CountdownEntry(date: Date(), event: .sample)
    }
}
```

**NEW BEHAVIOR:** Shows custom guide in widget gallery and when no event configured
```swift
func snapshot(for configuration: SelectEventIntent, in context: Context) async -> CountdownEntry {
    // In preview context (widget gallery), always show the guide
    if context.isPreview {
        return CountdownEntry(date: Date(), event: nil)
    }

    // Try to get real data based on selection
    if let event = await getEvent(for: configuration) {
        return CountdownEntry(date: Date(), event: event)
    } else {
        // No event configured - show custom setup guide
        return CountdownEntry(date: Date(), event: nil)
    }
}
```

---

### 2. TimeFillWidget.swift - Widget Definitions

#### Preview Timeline
**OLD BEHAVIOR:** Only showed sample events
```swift
#Preview("Minimal Small", as: .systemSmall) {
    MinimalCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}
```

**NEW BEHAVIOR:** First entry shows setup guide
```swift
#Preview("Minimal Small", as: .systemSmall) {
    MinimalCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: nil)  // Setup guide (first impression)
    CountdownEntry(date: .now, event: .sample)
    CountdownEntry(date: .now, event: .nearFuture)
}
```

**Widget Configuration (No Changes Needed):**
```swift
struct MinimalCountdownWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectEventIntent.self,
            provider: CountdownProvider()
        ) { entry in
            MinimalCountdownView(entry: entry)
                .containerBackground(Color(hex: "#0A0A0A"), for: .widget)
        }
        .configurationDisplayName("Minimal Countdown")
        .description("Clean, centered countdown. Tap to select an event.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()  // Ensures edge-to-edge layout
    }
}
```

---

### 3. MinimalCountdownView.swift & ModularCountdownView.swift - Widget Views

**EXISTING BEHAVIOR (Already Correct):**
Both views already check for `event == nil` and display SetupGuideView:

```swift
struct MinimalCountdownView: View {
    let entry: CountdownEntry

    var body: some View {
        if let event = entry.event {
            // Event is configured - show countdown
            Link(destination: URL(string: "timefill://event/\(event.id)")!) {
                // ... countdown view
            }
        } else {
            // No event configured - show setup guide
            SetupGuideView()
        }
    }
}
```

This pattern ensures:
- When `entry.event == nil` → SetupGuideView appears
- When `entry.event` has data → Countdown view appears

---

### 4. SetupGuideView.swift - Custom Placeholder View

**UPDATED:** Fixed text visibility issues
```swift
struct SetupGuideView: View {
    var body: some View {
        ZStack {
            // Pure dark background - consistent with main widgets
            LinearGradient(
                colors: [
                    Color(hex: "#0F0F0F"),
                    Color(hex: "#0A0A0A")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Title
                Text("Select Event")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white)  // Changed from .foregroundStyle
                    .padding(.bottom, 24)

                // Instruction 1: Touch and hold
                HStack(spacing: 12) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.white)  // Changed from .foregroundStyle
                        .frame(width: 28)

                    Text("Touch and hold the widget")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.85))
                        .multilineTextAlignment(.leading)
                }
                .padding(.bottom, 16)

                // Instruction 2: Edit Widget
                HStack(spacing: 12) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.white)
                        .frame(width: 28)

                    Text("Tap Edit Widget")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.85))
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
        }
        .preferredColorScheme(.dark)  // Force dark mode
    }
}
```

**Key Changes:**
- Changed from `.foregroundStyle()` to `.foregroundColor()` for better widget compatibility
- Switched to `Color.white` instead of `.white` for explicit color type
- Updated background to use gradient matching main widgets

---

## How It Works

### Widget Lifecycle Flow:

1. **User adds widget to home screen**
   - iOS calls `placeholder(in:)` immediately
   - Returns `CountdownEntry(event: nil)`
   - View detects nil event → Shows SetupGuideView ✅

2. **Widget gallery preview**
   - iOS calls `snapshot(for:in:)` with `context.isPreview == true`
   - Returns `CountdownEntry(event: nil)`
   - View shows SetupGuideView in gallery ✅

3. **After user configures widget**
   - iOS calls `timeline(for:in:)`
   - Provider fetches selected event
   - Returns `CountdownEntry(event: WidgetEventData)`
   - View shows countdown ✅

4. **No events in app**
   - Provider returns `CountdownEntry(event: nil)`
   - View shows SetupGuideView with instructions ✅

---

## Testing Steps

1. **Build & Run** (⌘R in Xcode)
2. **On iPhone:**
   - Long press home screen
   - Tap **+** button (top left)
   - Search for "Time Fill"
   - Select **Minimal Countdown** or **Modular Countdown**
   - Tap "Add Widget"

3. **Expected Result:**
   - Widget immediately shows dark background with white text:
     - **"Select Event"** (title, bold, centered)
     - 🤚 "Touch and hold the widget"
     - ℹ️ "Tap Edit Widget"
   - No gray system placeholder blocks

4. **Configure Widget:**
   - Long press widget → "Edit Widget"
   - Select an event from dropdown
   - Widget updates to show countdown

---

## System Placeholder Prevention Checklist

✅ `placeholder(in:)` returns nil event
✅ `snapshot(for:in:)` returns nil event when `context.isPreview`
✅ `snapshot(for:in:)` returns nil event when no data available
✅ Preview timelines start with nil event entry
✅ Widget views handle nil event with custom SetupGuideView
✅ SetupGuideView uses proper dark background colors
✅ SetupGuideView uses `.foregroundColor()` for widget compatibility
✅ `.contentMarginsDisabled()` prevents system padding
✅ `.preferredColorScheme(.dark)` forces dark mode
✅ No `.redacted(reason: .placeholder)` modifiers used

---

## Key Files Modified

1. **CountdownProvider.swift** - Lines 17-40
2. **TimeFillWidget.swift** - Lines 53-77
3. **SetupGuideView.swift** - Entire file (text visibility fix)
4. **MinimalCountdownView.swift** - No changes (already correct)
5. **ModularCountdownView.swift** - No changes (already correct)

---

## Result

When users add a Time Fill widget, they now see:
- **Immediate custom dark guide** instead of gray blocks
- **Clear instructions** on how to configure the widget
- **Consistent dark aesthetic** matching the app's design
- **No system placeholders** at any point in the widget lifecycle
