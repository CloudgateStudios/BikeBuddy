//
//  ContentView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Root view: shows the main tab bar, presenting the FTU flow as a full-screen modal
/// when the user has not yet completed first-time setup.
struct ContentView: View {

    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        MainTabView()
            .fullScreenCover(isPresented: $appViewModel.showFirstTimeUse) {
                FTUWelcomeView()
            }
            .task {
                // Load stations on first appearance if FTU is already done.
                if !appViewModel.showFirstTimeUse {
                    await appViewModel.refreshStationsIfNeeded()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await appViewModel.refreshStationsIfNeeded()
                }
            }
    }
}
