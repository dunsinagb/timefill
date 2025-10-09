//
//  NotificationSettingsView.swift
//  TimeFill
//
//  Created on 2025-10-06
//

import SwiftUI
import SwiftData

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var preferences: NotificationPreferences
    @State private var showingPermissionAlert = false
    let events: [CountdownEvent]

    init(events: [CountdownEvent]) {
        self.events = events
        _preferences = State(initialValue: NotificationPreferences.load())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.timeFillDarkBg
                    .ignoresSafeArea()

                if !notificationManager.isAuthorized {
                    // Permission request view
                    VStack(spacing: 24) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(Color.timeFillCyan)

                        VStack(spacing: 12) {
                            Text("Enable Notifications")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)

                            Text("Get notified when your countdowns are approaching")
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        VStack(spacing: 16) {
                            NotificationFeatureRow(
                                icon: "calendar",
                                title: "Event Day",
                                description: "Morning reminder on the big day"
                            )

                            NotificationFeatureRow(
                                icon: "clock.fill",
                                title: "1 Day Before",
                                description: "Evening reminder the day before"
                            )

                            NotificationFeatureRow(
                                icon: "calendar.badge.clock",
                                title: "1 Week Before",
                                description: "Weekly milestone notification"
                            )

                            NotificationFeatureRow(
                                icon: "calendar.circle.fill",
                                title: "1 Month Before",
                                description: "Monthly milestone notification"
                            )
                        }
                        .padding(.horizontal)

                        Button(action: {
                            Task {
                                let granted = await notificationManager.requestAuthorization()
                                if !granted {
                                    showingPermissionAlert = true
                                }
                            }
                        }) {
                            Text("Enable Notifications")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.timeFillCyan)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                } else {
                    // Settings view
                    List {
                        Section {
                            Toggle(isOn: $preferences.isEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Enable Notifications")
                                        .font(.system(.body, design: .rounded))
                                    Text("Receive alerts for upcoming events")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundStyle(.gray)
                                }
                            }
                            .tint(Color.timeFillCyan)
                            .onChange(of: preferences.isEnabled) { _, newValue in
                                if newValue {
                                    rescheduleAll()
                                } else {
                                    notificationManager.cancelAllNotifications()
                                }
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.05))

                        if preferences.isEnabled {
                            Section {
                                Toggle(isOn: $preferences.onEventDay) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("On Event Day")
                                            .font(.system(.body, design: .rounded))
                                        Text("9:00 AM on the event day")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(.gray)
                                    }
                                }
                                .tint(Color.timeFillCyan)
                                .onChange(of: preferences.onEventDay) { _, _ in
                                    rescheduleAll()
                                }

                                Toggle(isOn: $preferences.oneDayBefore) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("1 Day Before")
                                            .font(.system(.body, design: .rounded))
                                        Text("6:00 PM the day before")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(.gray)
                                    }
                                }
                                .tint(Color.timeFillCyan)
                                .onChange(of: preferences.oneDayBefore) { _, _ in
                                    rescheduleAll()
                                }

                                Toggle(isOn: $preferences.oneWeekBefore) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("1 Week Before")
                                            .font(.system(.body, design: .rounded))
                                        Text("6:00 PM one week before")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(.gray)
                                    }
                                }
                                .tint(Color.timeFillCyan)
                                .onChange(of: preferences.oneWeekBefore) { _, _ in
                                    rescheduleAll()
                                }

                                Toggle(isOn: $preferences.oneMonthBefore) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("1 Month Before")
                                            .font(.system(.body, design: .rounded))
                                        Text("6:00 PM one month before")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(.gray)
                                    }
                                }
                                .tint(Color.timeFillCyan)
                                .onChange(of: preferences.oneMonthBefore) { _, _ in
                                    rescheduleAll()
                                }
                            } header: {
                                Text("Notification Timing")
                                    .font(.system(.caption, design: .rounded))
                            }
                            .listRowBackground(Color.white.opacity(0.05))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        preferences.save()
                        dismiss()
                    }
                    .foregroundStyle(Color.timeFillCyan)
                }
            }
            .alert("Permission Denied", isPresented: $showingPermissionAlert) {
                Button("OK", role: .cancel) { }
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please enable notifications in Settings to receive alerts")
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            notificationManager.checkAuthorizationStatus()
            notificationManager.notificationPreferences = preferences
        }
    }

    private func rescheduleAll() {
        preferences.save()
        notificationManager.notificationPreferences = preferences
        notificationManager.rescheduleAllNotifications(for: events)
    }
}

struct NotificationFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.timeFillCyan)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text(description)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    NotificationSettingsView(events: [])
        .modelContainer(for: CountdownEvent.self, inMemory: true)
}
