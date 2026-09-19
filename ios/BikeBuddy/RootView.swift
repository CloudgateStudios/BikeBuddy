//
//  RootView.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Chooses the layout for the width the app has been given.
///
/// Replaces MainTabView. The tab bar is gone in both layouts: the map wants the whole
/// screen, and a bar pinned to the bottom is exactly where the stations sheet has to
/// live on a phone. Settings moved into the panel header instead.
///
/// Size class, not idiom — an iPad window dragged narrow in Split View or Stage
/// Manager gets the phone layout, which is the correct layout for that width.
struct RootView: View {

    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                PadLayout()
            } else {
                PhoneLayout()
            }
        }
        // A Spotlight result resolves to a station once the list can satisfy it, which
        // on a cold launch is well after the activity arrives. Selecting it here means
        // both layouts show it the same way they show any other choice, rather than
        // each needing a second path in.
        .onChange(of: appViewModel.deepLinkedStation?.id) { _, id in
            guard let id else { return }
            appViewModel.selectedStationID = id
            appViewModel.clearPendingStation()
        }
    }
}

// MARK: - Stations sheet

/// The stations sheet's resting geometry, shared because the map has to know what the
/// sheet is covering in order to frame anything underneath it.
enum StationsSheet {

    /// Where the sheet sits on launch, as a fraction of the height.
    static let restingFraction: CGFloat = 0.45

    /// The peek height. Enough for the header and a row, so the sheet still says what
    /// it is when it is out of the way.
    static let peekHeight: CGFloat = 150
}

// MARK: - Phone

/// Map behind, stations on a sheet over it. The sheet is always presented — it is the
/// app's primary surface, not a modal — so it cannot be dismissed, only dragged down
/// to its smallest detent.
private struct PhoneLayout: View {

    @Environment(AppViewModel.self) private var appViewModel

    @State private var detent: PresentationDetent = .fraction(StationsSheet.restingFraction)

    private static let peek: PresentationDetent = .height(StationsSheet.peekHeight)
    private static let resting: PresentationDetent = .fraction(StationsSheet.restingFraction)

    var body: some View {
        @Bindable var appViewModel = appViewModel

        MapView()
            .sheet(isPresented: .constant(!appViewModel.showFirstTimeUse)) {
                NavigationStack {
                    StationsPanel()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar(.hidden, for: .navigationBar)
                        .navigationDestination(item: $appViewModel.selectedStationID) { id in
                            if let station = appViewModel.station(withID: id) {
                                // The real map is right behind this sheet.
                                StationDetailView(station: station, showsMapHeader: false)
                            }
                        }
                }
                .presentationDetents([Self.peek, Self.resting, .large], selection: $detent)
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled(upThrough: Self.resting))
                .interactiveDismissDisabled()
            }
            // Choosing a pin while the sheet is parked at the peek would push the
            // detail behind the fold, so meet the selection halfway up.
            .onChange(of: appViewModel.selectedStationID) { _, id in
                if id != nil && detent == Self.peek {
                    detent = Self.resting
                }
            }
    }
}

// MARK: - iPad

/// Sidebar of stations against a full-height map. Choosing a station in either one
/// selects it in the other, because both read the same value.
private struct PadLayout: View {

    @Environment(AppViewModel.self) private var appViewModel

    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            StationsPanel()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.hidden, for: .navigationBar)
                .navigationSplitViewColumnWidth(min: 320, ideal: 380, max: 460)
        } detail: {
            MapView()
        }
        .navigationSplitViewStyle(.balanced)
    }
}
