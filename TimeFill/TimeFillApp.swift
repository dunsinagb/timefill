//
//  TimeFillApp.swift
//  TimeFill
//
//  Created on 2025-10-05
//

import SwiftUI
import SwiftData
import UserNotifications
import WidgetKit

@main
struct TimeFillApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var notificationDelegate = TimeFillNotificationDelegate()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasSeenLanding") private var hasSeenLanding = false
    @State private var showAddEventFromLanding = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CountdownEvent.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView(showAddEventFromLanding: $showAddEventFromLanding)
                    .environmentObject(notificationManager)
                    .onAppear {
                        setupNotifications()
                        // Force widget refresh when app launches
                        WidgetCenter.shared.reloadAllTimelines()
                        print("🔄 Forced widget reload on app launch")
                    }

                // Show landing page on first launch
                if !hasSeenLanding {
                    LandingView(hasSeenLanding: $hasSeenLanding) {
                        showAddEventFromLanding = true
                    }
                    .transition(AnyTransition.opacity.combined(with: .scale))
                    .zIndex(1)
                }
            }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Force widget refresh when app becomes active
                WidgetCenter.shared.reloadAllTimelines()
                print("🔄 Forced widget reload - app became active")
            }
        }
    }

    private func setupNotifications() {
        // Set up the notification delegate
        UNUserNotificationCenter.current().delegate = notificationDelegate

        // Check authorization status
        notificationManager.checkAuthorizationStatus()

        // Clear badge when app opens
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}

// MARK: - Notification Delegate

class TimeFillNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // Handle notification tap - you can add navigation logic here
        print("User tapped notification: \(userInfo)")

        // Clear badge and remove delivered notifications
        UNUserNotificationCenter.current().setBadgeCount(0)
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()

        completionHandler()
    }
}
