//
//  SimpleLockScreenProvider.swift
//  TimeFillWidget
//
//  Simple timeline provider for lock screen widgets (no intents)
//

import WidgetKit
import SwiftUI

// MARK: - Simple Lock Screen Provider
struct SimpleLockScreenProvider: TimelineProvider {
    typealias Entry = CountdownEntry

    func placeholder(in context: Context) -> CountdownEntry {
        // Always try to fetch real event
        if let event = fetchNextEvent() {
            return CountdownEntry(date: Date(), event: event)
        }
        // No event - return nil to show "No countdown"
        return CountdownEntry(date: Date(), event: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        let entry: CountdownEntry
        if let event = fetchNextEvent() {
            entry = CountdownEntry(date: Date(), event: event)
        } else {
            // No event - return nil to show "No countdown"
            entry = CountdownEntry(date: Date(), event: nil)
        }
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let currentDate = Date()

        // Fetch next event
        guard let event = fetchNextEvent() else {
            // No event - show "No countdown" with hourly refresh
            let entry = CountdownEntry(date: currentDate, event: nil)
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
            return
        }

        // Create entry with event
        let entry = CountdownEntry(date: currentDate, event: event)

        // Determine next update time based on event state
        let nextUpdate: Date
        if event.isInFinalMinute {
            // Update every second in final minute
            nextUpdate = currentDate.addingTimeInterval(1)
        } else if event.isToday || event.startsToday {
            // Update every minute when within 24 hours (active or scheduled)
            nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        } else {
            // Update every 15 minutes normally
            nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        }

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    // Fetch next event from shared UserDefaults
    private func fetchNextEvent() -> WidgetEventData? {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.timefill.app"),
              let eventData = sharedDefaults.data(forKey: "nextEvent"),
              let decoded = try? JSONDecoder().decode(SharedEventData.self, from: eventData) else {
            return nil
        }

        return WidgetEventData(
            id: decoded.id,
            name: decoded.name,
            targetDate: decoded.targetDate,
            createdDate: decoded.createdDate,
            colorHex: decoded.colorHex,
            iconName: decoded.iconName
        )
    }
}
