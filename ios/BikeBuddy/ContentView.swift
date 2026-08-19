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

    @Environment(AppViewModel.self) private var appViewModel

    var body: some View {
        @Bindable var appViewModel = appViewModel
        return MainTabView()
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
            // A Spotlight result opens the station directly rather than switching tabs,
            // so it behaves the same whichever tab the app was last left on. The item
            // stays nil until the station list can resolve the id, which is what makes
            // a cold launch work: the sheet appears once the stations finish loading.
            .sheet(item: spotlightStationBinding) { station in
                NavigationStack {
                    StationDetailView(station: station)
                }
            }
    }

    /// Presents the deep linked station, and clears the pending id when the sheet is
    /// dismissed so the same result can be tapped again later.
    private var spotlightStationBinding: Binding<Station?> {
        Binding(
            get: { appViewModel.showFirstTimeUse ? nil : appViewModel.deepLinkedStation },
            set: { newValue in
                if newValue == nil {
                    appViewModel.clearPendingStation()
                }
            }
        )
    }
}
