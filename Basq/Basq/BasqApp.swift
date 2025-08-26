//
//  BasqApp.swift
//  Basq
//
//  Created by PayneBrain on 8/25/25.
//

import SwiftUI
import UIKit

@main
struct BasqApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Prevent the system from dimming the display or hiding
                    // controls when the user is idle. This keeps the "Show
                    // Clock" button visible and the image at full brightness.
                    UIApplication.shared.isIdleTimerDisabled = true
                }
        }
        .onChange(of: scenePhase) { newPhase in
            // Re-enable the idle timer when the app is no longer active so
            // the system can manage power appropriately.
            UIApplication.shared.isIdleTimerDisabled = (newPhase == .active)
        }
    }
}
