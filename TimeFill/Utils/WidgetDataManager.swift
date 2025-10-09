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
    /// Update the next event data for widgets to display
    func updateNextEvent(_ event: CountdownEvent?) {
        guard let sharedDefaults = sharedDefaults else {
            print("❌ Failed to access shared UserDefaults")
            return
        }

        if let event = event {
            // Convert to codable struct
            let sharedEvent = SharedEventData(
                id: event.id.uuidString,  // Convert PersistentIdentifier to String
                name: event.name,
                targetDate: event.targetDate,
                createdDate: event.createdDate,
                colorHex: event.colorHex,
                iconName: event.iconName
            )

            // Encode and save
            if let encoded = try? JSONEncoder().encode(sharedEvent) {
                sharedDefaults.set(encoded, forKey: "nextEvent")
                sharedDefaults.synchronize()  // Force save
                print("✅ Widget data updated for: \(event.name)")
                print("✅ Event ID: \(event.id.uuidString)")
                print("✅ Target date: \(event.targetDate)")
            } else {
                print("❌ Failed to encode event")
            }
        } else {
            // Clear widget data
            sharedDefaults.removeObject(forKey: "nextEvent")
            print("🗑️ Widget data cleared")
        }

        // Request widget timeline reload
        WidgetCenter.shared.reloadAllTimelines()
        print("🔄 Requested widget reload")
    }

    // MARK: - Update with Events Array
    /// Find the next upcoming event and update widget, also save all events for selection
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

        // Get the next event
        let nextEvent = upcomingEvents.first

        if let nextEvent = nextEvent {
            print("📊 Next event: \(nextEvent.name) - \(nextEvent.targetDate)")
        } else {
            print("⚠️ No upcoming events found")
        }

        // Update next event
        updateNextEvent(nextEvent)

        // Save all events for widget selection menu
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

        // Also save simplified list for selection menu
        let eventListItems: [SharedEventListItem] = events.map { event in
            SharedEventListItem(
                id: event.id.uuidString,
                name: event.name,
                targetDate: event.targetDate
            )
        }

        // Encode and save both
        if let allEventsEncoded = try? JSONEncoder().encode(allEventsData) {
            sharedDefaults.set(allEventsEncoded, forKey: "allEvents")
            print("✅ Saved \(allEventsData.count) full events")
        }

        if let listItemsEncoded = try? JSONEncoder().encode(eventListItems) {
            sharedDefaults.set(listItemsEncoded, forKey: "eventList")
            print("✅ Saved \(eventListItems.count) event list items")
        }

        print("✅ Saved \(events.count) events for widget selection")
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
