//
//  SettingsView.swift
//  TimeFill
//
//  Created on 2025-10-05
//

import SwiftUI
import SwiftData


struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var events: [CountdownEvent]
    @AppStorage("autoDeleteCompleted") private var autoDeleteCompleted = false
    @State private var showingContactPopup = false
    @State private var showingShareSheet = false
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingNotificationSettings = false

    private var shareText: String {
        "Check out Time Fill - A beautiful countdown app to track your important moments! 🎉"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // App Header
                    VStack(spacing: 16) {
                        // App Icon/Logo
                        Image("SettingsLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.timeFillCyan.opacity(0.3), lineWidth: 3)
                            )
                            .shadow(color: Color.timeFillCyan.opacity(0.2), radius: 10, x: 0, y: 5)

                        // App Name - "Time" in white, "Fill" in cyan
                        HStack(spacing: 4) {
                            Text("Time")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            Text("Fill")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.timeFillCyan)
                        }

                        // Free Badge & Feature Description
                        VStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Text("Check out what the app can do")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundStyle(.gray)
                                Text("FREE")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.timeFillCyan)
                            }

                            // Features List
                            VStack(alignment: .leading, spacing: 10) {
                                FeatureRow(text: "Battery-Style Progress", subtitle: "Watch time fill beautifully, like a battery charging")
                                FeatureRow(text: "Year & Month Overview", subtitle: "See how much time has passed at a glance")
                                FeatureRow(text: "Live Home Screen Widgets", subtitle: "Track moments right from your home screen")
                                FeatureRow(text: "Smart Reminders", subtitle: "Notifications 1 month, 1 week, or 1 day before")
                                FeatureRow(text: "Instant Calendar Import", subtitle: "Add events from your calendar in seconds")
                                FeatureRow(text: "100% Private & Offline", subtitle: "No tracking, no cloud, no data collection")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.timeFillCyan.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.top, 8)

                    // Settings Sections
                    VStack(spacing: 20) {
                        // Contact Section
                        VStack(spacing: 12) {
                            SectionHeader(title: "Contact")

                            VStack(spacing: 0) {
                                Button(action: { withAnimation { showingContactPopup.toggle() } }) {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .foregroundStyle(Color.timeFillCyan)
                                            .frame(width: 24)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Get in Touch")
                                                .font(.system(.body, design: .rounded))
                                                .fontWeight(.medium)
                                                .foregroundStyle(.white)

                                            Text("Tap to view contact options")
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundStyle(.gray)
                                        }

                                        Spacer()

                                        Image(systemName: showingContactPopup ? "chevron.up" : "chevron.down")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.05))
                                    )
                                }

                                // Contact Popup
                                if showingContactPopup {
                                    VStack(spacing: 12) {
                                        // Email Display
                                        Text("agbolaboridunsin@gmail.com")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundStyle(.white)
                                            .padding(.top, 8)

                                        // Action Buttons
                                        HStack(spacing: 12) {
                                            Button(action: {
                                                UIPasteboard.general.string = "agbolaboridunsin@gmail.com"
                                            }) {
                                                HStack {
                                                    Image(systemName: "doc.on.doc.fill")
                                                    Text("Copy")
                                                }
                                                .font(.system(.subheadline, design: .rounded))
                                                .foregroundStyle(Color.timeFillCyan)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.timeFillCyan.opacity(0.2))
                                                )
                                            }

                                            Button(action: {
                                                if let url = URL(string: "mailto:agbolaboridunsin@gmail.com") {
                                                    UIApplication.shared.open(url)
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: "paperplane.fill")
                                                    Text("Email")
                                                }
                                                .font(.system(.subheadline, design: .rounded))
                                                .foregroundStyle(Color.timeFillCyan)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.timeFillCyan.opacity(0.2))
                                                )
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.03))
                                    )
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }

                            Text("Have feedback or need help? I'd love to hear from you!")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                        }

                        // Rate on App Store
                        VStack(spacing: 12) {
                            SectionHeader(title: "Rate on App Store")

                            Button(action: rateApp) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(Color.timeFillCyan)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Rate Time Fill")
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundStyle(.white)

                                        Text("Share your experience")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(.gray)
                                    }

                                    Spacer()

                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }

                            Text("Enjoying Time Fill? Please consider leaving a rating!")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                        }

                        // Notifications
                        VStack(spacing: 12) {
                            SectionHeader(title: "Notifications")

                            Button(action: { showingNotificationSettings = true }) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundStyle(Color.timeFillCyan)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Manage Notifications")
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundStyle(.white)

                                        Text(notificationManager.isAuthorized ? "Configure reminder alerts" : "Enable to get reminders")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(.gray)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                        }

                        // Delete Finished Events
                        VStack(spacing: 12) {
                            SectionHeader(title: "Delete Finished Events")

                            Toggle(isOn: $autoDeleteCompleted) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .foregroundStyle(Color.timeFillCyan)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Auto-delete completed events")
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundStyle(.white)

                                        Text("Automatically remove events after completion")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                            .tint(Color.timeFillCyan)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }

                        // Share App
                        VStack(spacing: 12) {
                            SectionHeader(title: "Share App")

                            Button(action: { showingShareSheet = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up.fill")
                                        .foregroundStyle(Color.timeFillCyan)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Share Time Fill")
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundStyle(.white)

                                        Text("Tell your friends about Time Fill")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(.gray)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                        }

                    }

                    // Footer
                    VStack(spacing: 4) {
                        Text("Made with ❤️  by Olu A.")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.gray)

                        Text("Version 1.0.0")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.gray.opacity(0.6))
                    }
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.timeFillDarkBg)
            .navigationTitle("Settings")
            .sheet(isPresented: $showingNotificationSettings) {
                NotificationSettingsView(events: events)
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [shareText])
            }
        }
    }

    private func rateApp() {
        // App Store rating URL - will need to be updated with actual App ID
        if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(.footnote, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .textCase(.uppercase)
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let text: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.timeFillCyan)
                .font(.system(size: 16))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    let events: [CountdownEvent]
    @State private var showingShareSheet = false
    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.timeFillDarkBg
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.timeFillCyan)

                    VStack(spacing: 8) {
                        Text("Export Your Data")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text("Export all your events as a JSON file")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                    }

                    Button(action: exportData) {
                        Text("Export \(events.count) Event\(events.count == 1 ? "" : "s")")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.timeFillCyan)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    Text("Your data is stored locally and never leaves your device unless you choose to export it.")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.timeFillCyan)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func exportData() {
        let exportData = events.map { event in
            [
                "id": event.id.uuidString,
                "name": event.name,
                "targetDate": ISO8601DateFormatter().string(from: event.targetDate),
                "createdDate": ISO8601DateFormatter().string(from: event.createdDate),
                "colorHex": event.colorHex,
                "iconName": event.iconName
            ]
        }

        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {

            let fileName = "TimeFill_Export_\(Date().timeIntervalSince1970).json"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            do {
                try jsonString.write(to: tempURL, atomically: true, encoding: .utf8)
                exportURL = tempURL
                showingShareSheet = true
            } catch {
                print("Error exporting data: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: CountdownEvent.self, inMemory: true)
}
