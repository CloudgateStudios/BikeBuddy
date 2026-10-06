//
//  ContentView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Root view: shows the map-and-stations layout, presenting the FTU flow as a
/// full-screen modal when the user has not yet completed first-time setup.
struct ContentView: View {

    @Environment(AppViewModel.self) private var appViewModel
    @Environment(LocationManager.self) private var locationManager
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        @Bindable var appViewModel = appViewModel
        return RootView()
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
            // Updates follow the app rather than any one view. The panel and the map
            // both come and go — the panel moves between the sheet and the landscape
            // column on every rotation — and a shared manager stopped by whichever
            // disappeared first would leave the other without a fix. Inactive (a
            // pulled-down Control Center, an incoming call) keeps running.
            .onChange(of: scenePhase, initial: true) { _, phase in
                switch phase {
                case .active:
                    locationManager.startUpdatingLocation()
                case .background:
                    locationManager.stopUpdatingLocation()
                default:
                    break
                }
            }
            .onChange(of: locationManager.coordinate.latitude, initial: true) { _, _ in
                appViewModel.userCoordinate = locationManager.coordinate
            }
    }
}
