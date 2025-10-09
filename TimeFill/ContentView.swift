//
//  ContentView.swift
//  TimeFill
//
//  Created on 2025-10-05
//

import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @Binding var showAddEventFromLanding: Bool
    @State private var selectedTab = 0
    @State private var isShowingDetailView = false
    @State private var selectedEventID: String?  // For deep linking from widget
    @Query private var allEvents: [CountdownEvent]
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.modelContext) private var modelContext
    @AppStorage("autoDeleteCompleted") private var autoDeleteCompleted = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(showAddEventFromLanding: $showAddEventFromLanding)
                    .environment(\.isShowingDetailView, $isShowingDetailView)
                    .tabItem {
                        Label("Overview", systemImage: "list.bullet")
                    }
                    .tag(0)

                EventTimelineView()
                    .tabItem {
                        Label("Timeline", systemImage: "timeline.selection")
                    }
                    .tag(1)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(2)
            }
        }
        .onAppear {
            // Schedule notifications for existing events
            scheduleNotificationsIfNeeded()
            // Check for completed events to delete
            deleteCompletedEventsIfNeeded()
        }
        .onChange(of: allEvents) { _, _ in
            // Reschedule notifications when events change
            scheduleNotificationsIfNeeded()
            // Check for completed events to delete
            deleteCompletedEventsIfNeeded()
        }
        .onChange(of: autoDeleteCompleted) { _, newValue in
            // When setting is toggled on, immediately delete completed events
            if newValue {
                deleteCompletedEventsIfNeeded()
            }
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }
    
    private func scheduleNotificationsIfNeeded() {
        guard notificationManager.isAuthorized else { return }

        // Only reschedule if notifications are enabled
        let preferences = NotificationPreferences.load()
        if preferences.isEnabled {
            notificationManager.rescheduleAllNotifications(for: allEvents)
        }
    }

    /// Delete completed events if auto-delete setting is enabled
    private func deleteCompletedEventsIfNeeded() {
        guard autoDeleteCompleted else { return }

        let now = Date()
        let completedEvents = allEvents.filter { $0.targetDate < now }

        // Delete completed events
        for event in completedEvents {
            modelContext.delete(event)
        }

        // Save context if there were deletions
        if !completedEvents.isEmpty {
            try? modelContext.save()
            print("🗑️ Auto-deleted \(completedEvents.count) completed event(s)")
        }
    }

    /// Handle deep link from widget tap
    private func handleDeepLink(_ url: URL) {
        // Parse URL: timefill://event/{eventID}
        guard url.scheme == "timefill",
              url.host() == "event",
              let eventID = url.pathComponents.dropFirst().first else {
            print("Invalid deep link URL: \(url)")
            return
        }

        print("📱 Deep link received for event ID: \(eventID)")

        // Find the event with matching UUID
        if allEvents.contains(where: { $0.id.uuidString == eventID }) {
            // Switch to Overview tab
            selectedTab = 0
            // Set the selected event ID (HomeView will pick this up)
            selectedEventID = eventID
        } else {
            print("⚠️ Event not found for ID: \(eventID)")
        }
    }
}

#Preview {
    ContentView(showAddEventFromLanding: .constant(false))
        .modelContainer(for: CountdownEvent.self, inMemory: true)
        .environmentObject(NotificationManager.shared)
}
