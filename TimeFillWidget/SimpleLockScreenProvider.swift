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

        var entries: [CountdownEntry] = []
        entries.append(CountdownEntry(date: currentDate, event: event))

        // Determine next update time based on event state
        var refreshDate: Date
        if event.isInFinalMinute {
            // In final minute - create per-second entries up to completion
            let secondsRemaining = event.secondsRemaining
            for second in 1...secondsRemaining {
                let entryDate = currentDate.addingTimeInterval(TimeInterval(second))
                entries.append(CountdownEntry(date: entryDate, event: event))
            }
            // Add completion entry
            entries.append(CountdownEntry(date: event.targetDate.addingTimeInterval(0.5), event: event))
            // Add transition entry showing the next event
            let nextEvent = fetchNextEventAfter(event.targetDate)
            entries.append(CountdownEntry(date: event.targetDate.addingTimeInterval(2), event: nextEvent))
            refreshDate = event.targetDate.addingTimeInterval(60)
        } else if event.isToday || event.startsToday {
            let nextMinute = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
            refreshDate = nextMinute
            // If event completes before the next minute update, add a transition entry
            if event.targetDate <= nextMinute && !event.isScheduled {
                let nextEvent = fetchNextEventAfter(event.targetDate)
                entries.append(CountdownEntry(date: event.targetDate.addingTimeInterval(1), event: nextEvent))
                refreshDate = event.targetDate.addingTimeInterval(60)
            }
        } else {
            refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        }

        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }

    // Fetch the next upcoming event whose targetDate is after the specified date.
    // Used to pre-compute which event to show when the current one completes.
    private func fetchNextEventAfter(_ date: Date) -> WidgetEventData? {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.timefill.app"),
              let allEventsData = sharedDefaults.data(forKey: "allEvents"),
              let allEvents = try? JSONDecoder().decode([SharedEventData].self, from: allEventsData) else {
            return nil
        }

        let upcomingEvents = allEvents
            .filter { $0.targetDate > date }
            .sorted { $0.targetDate < $1.targetDate }

        guard let nextEventData = upcomingEvents.first else {
            return nil
        }

        return WidgetEventData(
            id: nextEventData.id,
            name: nextEventData.name,
            targetDate: nextEventData.targetDate,
            createdDate: nextEventData.createdDate,
            colorHex: nextEventData.colorHex,
            iconName: nextEventData.iconName
        )
    }

    // Fetch next event from shared UserDefaults
    // ALWAYS filters to ensure we get the real next upcoming event
    private func fetchNextEvent() -> WidgetEventData? {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.timefill.app"),
              let allEventsData = sharedDefaults.data(forKey: "allEvents"),
              let allEvents = try? JSONDecoder().decode([SharedEventData].self, from: allEventsData) else {
            return nil
        }

        // Filter for upcoming events and sort by date
        let upcomingEvents = allEvents
            .filter { $0.targetDate > Date() }
            .sorted { $0.targetDate < $1.targetDate }

        guard let nextEventData = upcomingEvents.first else {
            return nil
        }

        return WidgetEventData(
            id: nextEventData.id,
            name: nextEventData.name,
            targetDate: nextEventData.targetDate,
            createdDate: nextEventData.createdDate,
            colorHex: nextEventData.colorHex,
            iconName: nextEventData.iconName
        )
    }
}
