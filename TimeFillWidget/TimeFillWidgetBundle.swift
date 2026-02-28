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
        // Home screen countdown widgets
        MinimalCountdownWidget()
        ModularCountdownWidget()
        DotRingCountdownWidget()

        // Calendar progress widgets
        YearProgressWidget()
        MonthProgressWidget()

        // Lock screen countdown widget
        LockScreenCountdownWidget()

        // Keep existing widgets if needed
        // TimeFillWidgetControl()
        // TimeFillWidgetLiveActivity()
    }
}
