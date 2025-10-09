//
//  DetailViewEnvironmentKey.swift
//  TimeFill
//
//  Created on 2025-10-07
//

import SwiftUI

// Environment key to track when DetailView is shown
private struct IsShowingDetailViewKey: EnvironmentKey {
    static let defaultValue: Binding<Bool>? = nil
}

extension EnvironmentValues {
    var isShowingDetailView: Binding<Bool>? {
        get { self[IsShowingDetailViewKey.self] }
        set { self[IsShowingDetailViewKey.self] = newValue }
    }
}
