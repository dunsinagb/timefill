//
//  CountdownProvider.swift
//  TimeFillWidget
//
//  Timeline provider for countdown widgets
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Countdown Timeline Provider
struct CountdownProvider: AppIntentTimelineProvider {
    typealias Entry = CountdownEntry
    typealias Intent = SelectEventIntent

    // MARK: - Placeholder
    /// Returns a placeholder entry while widget is loading
    /// Shows sample birthday for gallery preview
    func placeholder(in context: Context) -> CountdownEntry {
        // Show hardcoded birthday sample for gallery
        // This is what appears in the widget gallery
        print("🔷 Placeholder called - showing sample birthday")
        return CountdownEntry(date: Date(), event: .sample)
    }

    // MARK: - Snapshot
    /// Returns a single entry for widget gallery and transient situations
    func snapshot(for configuration: SelectEventIntent, in context: Context) async -> CountdownEntry {
        print("📸 Snapshot called - isPreview: \(context.isPreview), family: \(context.family)")
        print("📸 Selected event ID: \(configuration.selectedEvent.id)")

        // ALWAYS try to fetch actual event based on configuration
        if let event = await getEvent(for: configuration) {
            print("✅ Showing real event: \(event.name)")
            return CountdownEntry(date: Date(), event: event)
        } else {
            // No events available - show setup guide instructions
            print("✅ No events found - showing setup guide")
            return CountdownEntry(date: Date(), event: nil)
        }
    }

    // MARK: - Timeline
    /// Returns a timeline of entries for the widget to display
    /// This is THE definitive source for widget content after it's added to home screen
    func timeline(for configuration: SelectEventIntent, in context: Context) async -> Timeline<CountdownEntry> {
        print("📊 Timeline called - family: \(context.family)")

        // Get the event based on user selection
        // Returns nil if no events exist or selected event not found
        let event = await getEvent(for: configuration)

        print("📊 Event result: \(event?.name ?? "nil")")

        let currentDate = Date()

        // Determine refresh policy based on event state
        if let event = event {
            if event.isInFinalMinute {
                // In final minute - update every second for stopwatch countdown
                var entries: [CountdownEntry] = []
                let secondsRemaining = event.secondsRemaining

                // Create entries for countdown
                for second in 0...secondsRemaining {
                    let entryDate = currentDate.addingTimeInterval(TimeInterval(second))
                    entries.append(CountdownEntry(date: entryDate, event: event))
                }

                // Add final entry at target date to show "DONE" and checkmark
                entries.append(CountdownEntry(date: event.targetDate.addingTimeInterval(0.5), event: event))

                print("📊 Event in final minute - creating \(entries.count) entries (including completion entry)")
                // After completion, update once per day
                return Timeline(entries: entries, policy: .after(event.targetDate.addingTimeInterval(86400)))
            } else if event.isCompleted {
                // Event completed - show checkmark, update once per day
                let entry = CountdownEntry(date: currentDate, event: event)
                let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                print("📊 Event completed - showing checkmark, next update in 24 hours")
                return Timeline(entries: [entry], policy: .after(nextUpdate))
            } else {
                // Normal countdown - update every 15 minutes
                let entry = CountdownEntry(date: currentDate, event: event)
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
                print("📊 Normal countdown - next update in 15 minutes")
                return Timeline(entries: [entry], policy: .after(nextUpdate))
            }
        } else {
            // No event - show setup guide, update every hour
            let entry = CountdownEntry(date: currentDate, event: nil)
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            print("📊 No event - showing setup guide, next update in 1 hour")
            return Timeline(entries: [entry], policy: .after(nextUpdate))
        }
    }

    // MARK: - Get Event Based on Selection
    /// Fetches the appropriate event based on user's widget configuration
    /// Returns nil if no event is configured - triggers setup guide view
    private func getEvent(for configuration: SelectEventIntent) async -> WidgetEventData? {
        let selectedEventID = configuration.selectedEvent.id

        // If "auto" mode, get the next upcoming event
        if selectedEventID == "auto" {
            let event = await getNextEvent()

            // If auto mode but no events available, return nil to show setup guide
            if event == nil {
                print("⚠️ Auto mode active but no events found - showing setup guide")
            }

            return event
        } else {
            // Get the specific event the user selected
            let event = await getEventByID(selectedEventID)

            if event == nil {
                print("⚠️ Selected event not found - showing setup guide")
            }

            return event
        }
    }

    // MARK: - Fetch Next Event
    /// Fetch the next upcoming event from shared UserDefaults
    private func getNextEvent() async -> WidgetEventData? {
        // Use App Group to share data between app and widget
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.timefill.app") else {
            print("❌ Failed to access shared UserDefaults")
            return nil
        }

        // Try to get event data from shared UserDefaults
        guard let eventData = sharedDefaults.data(forKey: "nextEvent") else {
            print("❌ No 'nextEvent' data found in UserDefaults")
            return nil
        }

        guard let decoded = try? JSONDecoder().decode(SharedEventData.self, from: eventData) else {
            print("❌ Failed to decode nextEvent data")
            return nil
        }

        print("✅ Successfully loaded next event: \(decoded.name)")

        return WidgetEventData(
            id: decoded.id,
            name: decoded.name,
            targetDate: decoded.targetDate,
            createdDate: decoded.createdDate,
            colorHex: decoded.colorHex,
            iconName: decoded.iconName
        )
    }

    // MARK: - Fetch Specific Event by ID
    /// Fetch a specific event by its ID from the event list
    private func getEventByID(_ eventID: String) async -> WidgetEventData? {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.timefill.app"),
              let allEventsData = sharedDefaults.data(forKey: "allEvents"),
              let allEvents = try? JSONDecoder().decode([SharedEventData].self, from: allEventsData) else {
            return nil
        }

        // Find the event with matching ID
        guard let event = allEvents.first(where: { $0.id == eventID }) else {
            return nil
        }

        return WidgetEventData(
            id: event.id,
            name: event.name,
            targetDate: event.targetDate,
            createdDate: event.createdDate,
            colorHex: event.colorHex,
            iconName: event.iconName
        )
    }
}

// MARK: - Shared Event Data
/// Codable struct for sharing event data via UserDefaults
struct SharedEventData: Codable {
    let id: String  // Event ID for deep linking
    let name: String
    let targetDate: Date
    let createdDate: Date
    let colorHex: String
    let iconName: String
}
