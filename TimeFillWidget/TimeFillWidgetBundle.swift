//
//  TimeFillWidgetBundle.swift
//  TimeFillWidget
//
//  Widget bundle containing all Time Fill widgets
//

import WidgetKit
import SwiftUI

@main
struct TimeFillWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Countdown widgets
        MinimalCountdownWidget()
        ModularCountdownWidget()

        // Keep existing widgets if needed
        // TimeFillWidgetControl()
        // TimeFillWidgetLiveActivity()
    }
}
