//
//  TimeFillWidget.swift
//  TimeFillWidget
//
//  Main widget definitions
//

import WidgetKit
import SwiftUI

// MARK: - Minimal Countdown Widget
/// Clean, centered countdown widget - user can select any event
struct MinimalCountdownWidget: Widget {
    let kind: String = "MinimalCountdownWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectEventIntent.self,
            provider: CountdownProvider()
        ) { entry in
            MinimalCountdownView(entry: entry)
                .containerBackground(for: .widget) {
                    // Dark background for setup guide - gradient handled in countdown view
                    LinearGradient(
                        colors: [
                            Color(hex: "#0F0F0F"),
                            Color(hex: "#0A0A0A")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .configurationDisplayName("Minimal Countdown")
        .description("Clean, centered countdown. Tap to select an event.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

// MARK: - Modular Countdown Widget
/// Data-rich countdown widget - user can select any event
struct ModularCountdownWidget: Widget {
    let kind: String = "ModularCountdownWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectEventIntent.self,
            provider: CountdownProvider()
        ) { entry in
            ModularCountdownView(entry: entry)
                .containerBackground(for: .widget) {
                    // Dark background for setup guide - gradient handled in countdown view
                    LinearGradient(
                        colors: [
                            Color(hex: "#0F0F0F"),
                            Color(hex: "#0A0A0A")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .configurationDisplayName("Modular Countdown")
        .description("Data-rich countdown. Long press to select an event.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

// MARK: - Previews
// Gallery shows sample birthday event, timeline shows sample data
#Preview("Minimal Small", as: .systemSmall) {
    MinimalCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)  // Gallery: "My Birthday" with 45 days
    CountdownEntry(date: .now, event: .nearFuture)
}

#Preview("Modular Small", as: .systemSmall) {
    ModularCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)  // Gallery: "My Birthday" with 45 days
    CountdownEntry(date: .now, event: .nearFuture)
}

#Preview("Modular Medium", as: .systemMedium) {
    ModularCountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)  // Gallery: "My Birthday" with 45 days
    CountdownEntry(date: .now, event: .nearFuture)
}
