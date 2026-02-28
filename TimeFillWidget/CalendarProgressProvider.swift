//
//  CalendarProgressProvider.swift
//  TimeFillWidget
//
//  Timeline provider for calendar-based progress widgets (year/month)
//

import WidgetKit
import SwiftUI

// MARK: - Calendar Entry
struct CalendarEntry: TimelineEntry {
    let date: Date
}

// MARK: - Calendar Progress Provider
struct CalendarProgressProvider: TimelineProvider {
    typealias Entry = CalendarEntry

    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        completion(CalendarEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let now = Date()
        let entry = CalendarEntry(date: now)

        // Refresh at next midnight so the dot counts update each day
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)

        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}
