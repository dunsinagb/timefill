//
//  ReanimationKey.swift
//  TimeFill
//
//  Created on 2025-10-06
//

import SwiftUI

// Environment key to trigger re-animation
private struct ReanimationTriggerKey: EnvironmentKey {
    static let defaultValue: ((UUID) -> Void)? = nil
}

extension EnvironmentValues {
    var triggerReanimation: ((UUID) -> Void)? {
        get { self[ReanimationTriggerKey.self] }
        set { self[ReanimationTriggerKey.self] = newValue }
    }
}
