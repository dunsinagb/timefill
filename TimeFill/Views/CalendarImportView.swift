//
//  CalendarImportView.swift
//  TimeFill
//
//  Created on 2025-10-06
//

import SwiftUI
import SwiftData
import EventKit

// Wrapper to make EKEvent uniquely identifiable
struct UniqueEvent: Identifiable {
    let id: String
    let event: EKEvent

    init(event: EKEvent) {
        self.event = event
        // Create unique ID from event identifier + start date timestamp
        self.id = "\(event.eventIdentifier ?? UUID().uuidString)-\(event.startDate.timeIntervalSince1970)"
    }
}

struct CalendarImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var importer = CalendarImporter()

    @State private var selectedEvents: Set<String> = []
    @State private var calendarEvents: [UniqueEvent] = []
    @State private var showingPermissionAlert = false

    // Optional callback to dismiss parent sheet
    var onDismissToRoot: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.timeFillDarkBg
                    .ignoresSafeArea()

                if !importer.isAuthorized {
                    // Permission request view
                    VStack(spacing: 24) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 72))
                            .foregroundStyle(Color.timeFillCyan)

                        VStack(spacing: 12) {
                            Text("Import from Calendar")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)

                            Text("Time Fill needs access to your calendar to import events")
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        Button(action: {
                            Task {
                                let granted = await importer.requestAccess()
                                if granted {
                                    loadCalendarEvents()
                                } else {
                                    showingPermissionAlert = true
                                }
                            }
                        }) {
                            Text("Grant Access")
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
                } else if calendarEvents.isEmpty {
                    // No events found
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 64))
                            .foregroundStyle(.gray)

                        Text("No upcoming events")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        Text("No events found in the next 12 months")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.gray)
                    }
                } else {
                    // Events list
                    VStack(spacing: 0) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select Events to Import")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)

                            Text("\(selectedEvents.count) of \(calendarEvents.count) selected")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()

                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(calendarEvents) { uniqueEvent in
                                    CalendarEventRow(
                                        event: uniqueEvent.event,
                                        isSelected: selectedEvents.contains(uniqueEvent.id)
                                    ) {
                                        toggleSelection(uniqueEvent)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }

                if !calendarEvents.isEmpty {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Import") {
                            importSelectedEvents()
                        }
                        .foregroundStyle(Color.timeFillCyan)
                        .disabled(selectedEvents.isEmpty)
                    }
                }
            }
            .alert("Permission Denied", isPresented: $showingPermissionAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Please enable calendar access in Settings to import events")
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if importer.isAuthorized {
                loadCalendarEvents()
            }
        }
    }

    private func loadCalendarEvents() {
        let events = importer.getUpcomingEvents()
        calendarEvents = events.map { UniqueEvent(event: $0) }
    }

    private func toggleSelection(_ uniqueEvent: UniqueEvent) {
        if selectedEvents.contains(uniqueEvent.id) {
            selectedEvents.remove(uniqueEvent.id)
        } else {
            selectedEvents.insert(uniqueEvent.id)
        }
    }

    private func importSelectedEvents() {
        let eventsToImport = calendarEvents
            .filter { selectedEvents.contains($0.id) }
            .map { $0.event }
        importer.importEvents(eventsToImport, into: modelContext)

        // If callback is provided, use it to dismiss parent sheet too
        if let onDismissToRoot = onDismissToRoot {
            dismiss()  // Dismiss calendar import
            // Small delay to ensure this sheet dismisses first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onDismissToRoot()  // Dismiss parent AddEventView
            }
        } else {
            dismiss()  // Just dismiss this sheet
        }
    }
}

struct CalendarEventRow: View {
    let event: EKEvent
    let isSelected: Bool
    let onTap: () -> Void

    private var daysUntil: Int {
        let components = Calendar.current.dateComponents([.day], from: Date(), to: event.startDate)
        return max(components.day ?? 0, 0)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.timeFillCyan : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.timeFillCyan)
                            .frame(width: 16, height: 16)
                    }
                }

                // Event info
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title ?? "Untitled")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Text(event.startDate, format: .dateTime.month().day().year())
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.gray)

                        Text("·")
                            .foregroundStyle(.gray)

                        Text("in \(daysUntil)d")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Color.timeFillCyan)
                    }
                }

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.08 : 0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.timeFillCyan.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CalendarImportView()
        .modelContainer(for: CountdownEvent.self, inMemory: true)
}
