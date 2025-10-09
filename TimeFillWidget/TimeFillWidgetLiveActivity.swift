//
//  TimeFillWidgetLiveActivity.swift
//  TimeFillWidget
//
//  Created by Dunsin Agbolabori on 10/7/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimeFillWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TimeFillWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimeFillWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TimeFillWidgetAttributes {
    fileprivate static var preview: TimeFillWidgetAttributes {
        TimeFillWidgetAttributes(name: "World")
    }
}

extension TimeFillWidgetAttributes.ContentState {
    fileprivate static var smiley: TimeFillWidgetAttributes.ContentState {
        TimeFillWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TimeFillWidgetAttributes.ContentState {
         TimeFillWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TimeFillWidgetAttributes.preview) {
   TimeFillWidgetLiveActivity()
} contentStates: {
    TimeFillWidgetAttributes.ContentState.smiley
    TimeFillWidgetAttributes.ContentState.starEyes
}
