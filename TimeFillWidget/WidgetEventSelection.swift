//
//  WidgetEventSelection.swift
//  TimeFillWidget
//
//  Event selection system for configurable widgets
//

import Foundation
import AppIntents
import WidgetKit

// MARK: - Event Selection Entity
/// Represents a selectable event for widget configuration
struct EventEntity: AppEntity {
    let id: String
    let name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Event"
    static var defaultQuery = EventQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    // Special "Auto" option for automatic event selection
    static let autoEvent = EventEntity(id: "auto", name: "Next Upcoming Event (Auto)")
}

// MARK: - Event Query
/// Provides available events for selection
struct EventQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [EventEntity] {
        let allEvents = await fetchAvailableEvents()
        return allEvents.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [EventEntity] {
        // Auto option first, then all available events
        var events = [EventEntity.autoEvent]
        let availableEvents = await fetchAvailableEvents()
        events.append(contentsOf: availableEvents)
        return events
    }

    func defaultResult() async -> EventEntity? {
        return EventEntity.autoEvent  // Default to auto mode
    }

    // Fetch events from shared UserDefaults
    private func fetchAvailableEvents() async -> [EventEntity] {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.timefill.app"),
              let eventsData = sharedDefaults.data(forKey: "eventList"),
              let events = try? JSONDecoder().decode([SharedEventListItem].self, from: eventsData) else {
            print("⚠️ No events found in eventList")
            return []
        }

        print("✅ Found \(events.count) events for selection")
        return events.map { event in
            EventEntity(id: event.id, name: event.name)
        }
    }
}

// MARK: - Widget Configuration Intent
/// Intent for configuring which event to display
struct SelectEventIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Event"
    static var description = IntentDescription("Choose which event to display in the widget")

    @Parameter(title: "Event", default: EventEntity.autoEvent)
    var selectedEvent: EventEntity

    init() {
        self.selectedEvent = EventEntity.autoEvent
    }

    init(selectedEvent: EventEntity) {
        self.selectedEvent = selectedEvent
    }
}

// MARK: - Shared Event List Item
/// Lightweight event data for widget selection menu
struct SharedEventListItem: Codable {
    let id: String
    let name: String
    let targetDate: Date
}
