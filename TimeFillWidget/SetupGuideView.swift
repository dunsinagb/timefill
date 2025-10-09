//
//  SetupGuideView.swift
//  TimeFillWidget
//
//  Initial setup guide shown when widget is first added
//

import SwiftUI
import WidgetKit

// MARK: - Setup Guide View
/// Instructional view shown when widget has no configuration
/// Guides user to long press and edit widget to select an event
struct SetupGuideView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Title
            Text("Select Event")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.bottom, 24)

            // Instruction 1: Touch and hold
            HStack(spacing: 12) {
                Image(systemName: "hand.tap")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 28)

                Text("Touch and hold the widget")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.leading)
            }
            .padding(.bottom, 16)

            // Instruction 2: Edit Widget
            HStack(spacing: 12) {
                Image(systemName: "info.circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 28)

                Text("Tap Edit Widget")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.leading)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    MinimalCountdownWidget()
} timeline: {
    // Empty entry to show setup guide
    CountdownEntry(date: .now, event: nil)
}
