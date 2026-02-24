//
//  WidgetDataManager.swift
//  TimeFill
//
//  Manages sharing data between app and widgets
//

import Foundation
import WidgetKit

class WidgetDataManager {
    static let shared = WidgetDataManager()

    private let sharedDefaults = UserDefaults(suiteName: "group.com.timefill.app")

    private init() {}

    // MARK: - Update Widget Data
    /// Write the next event to shared UserDefaults (does NOT trigger timeline reload)
    private func writeNextEvent(_ event: CountdownEvent?, to sharedDefaults: UserDefaults) {
        if let event = event {
            let sharedEvent = SharedEventData(
                id: event.id.uuidString,
                name: event.name,
                targetDate: event.targetDate,
                createdDate: event.createdDate,
                colorHex: event.colorHex,
                iconName: event.iconName
            )

            if let encoded = try? JSONEncoder().encode(sharedEvent) {
                sharedDefaults.set(encoded, forKey: "nextEvent")
                print("✅ Widget data updated for: \(event.name)")
            } else {
                print("❌ Failed to encode event")
            }
        } else {
            sharedDefaults.removeObject(forKey: "nextEvent")
            print("🗑️ Widget data cleared")
        }
    }

    // MARK: - Update with Events Array
    /// Write all event data to shared UserDefaults, then trigger a single widget reload.
    /// All data is flushed before the reload so widgets always read fresh data.
    func updateWithEvents(_ events: [CountdownEvent]) {
        guard let sharedDefaults = sharedDefaults else {
            print("❌ Failed to access shared UserDefaults in updateWithEvents")
            return
        }

        print("📊 updateWithEvents called with \(events.count) events")

        // Filter for upcoming events
        let upcomingEvents = events
            .filter { $0.targetDate > Date() }
            .sorted { $0.targetDate < $1.targetDate }

        print("📊 Found \(upcomingEvents.count) upcoming events")

        let nextEvent = upcomingEvents.first

        if let nextEvent = nextEvent {
            print("📊 Next event: \(nextEvent.name) - \(nextEvent.targetDate)")
        } else {
            print("⚠️ No upcoming events found")
        }

        // 1. Write next event
        writeNextEvent(nextEvent, to: sharedDefaults)

        // 2. Write all events for widget timeline providers
        let allEventsData: [SharedEventData] = events.map { event in
            SharedEventData(
                id: event.id.uuidString,
                name: event.name,
                targetDate: event.targetDate,
                createdDate: event.createdDate,
                colorHex: event.colorHex,
                iconName: event.iconName
            )
        }

        if let allEventsEncoded = try? JSONEncoder().encode(allEventsData) {
            sharedDefaults.set(allEventsEncoded, forKey: "allEvents")
            print("✅ Saved \(allEventsData.count) full events")
        }

        // 3. Write simplified list for widget selection menu
        let eventListItems: [SharedEventListItem] = events.map { event in
            SharedEventListItem(
                id: event.id.uuidString,
                name: event.name,
                targetDate: event.targetDate
            )
        }

        if let listItemsEncoded = try? JSONEncoder().encode(eventListItems) {
            sharedDefaults.set(listItemsEncoded, forKey: "eventList")
            print("✅ Saved \(eventListItems.count) event list items")
        }

        // 4. Force flush to disk before triggering widget reload
        sharedDefaults.synchronize()

        // 5. NOW trigger widget reload — all data is guaranteed to be readable
        WidgetCenter.shared.reloadAllTimelines()
        print("🔄 Requested widget reload (all data written first)")
    }
}

// MARK: - Shared Event List Item
/// Lightweight event data for widget selection menu
struct SharedEventListItem: Codable {
    let id: String
    let name: String
    let targetDate: Date
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
