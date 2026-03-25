//
//  MapView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import MapKit
import BikeBuddyKit

/// Shows all bike stations as map annotations.
/// Tapping a station pin navigates to StationDetailView.
struct MapView: View {

    @EnvironmentObject var appViewModel: AppViewModel

    @State private var selectedStation: Station?
    @State private var navigateToDetail = false
    @State private var updatedAtText: String = ""

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            Map {
                UserAnnotation()
                ForEach(appViewModel.stations, id: \.id) { station in
                    Marker(station.stationName, coordinate: station.coordinate)
                        .tint(Color("BikeBuddyBlue"))
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompassButton()
            }
            .ignoresSafeArea(edges: .bottom)

            if !updatedAtText.isEmpty {
                Text(updatedAtText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(6)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 8)
            }
        }
        .navigationTitle(StringsService.getStringFor(key: "MapNavBarTitle"))
        .navigationDestination(isPresented: $navigateToDetail) {
            if let station = selectedStation {
                StationDetailView(station: station)
            }
        }
        .onChange(of: appViewModel.stationsLastUpdated) { _, _ in
            updateTimestampLabel()
        }
        .onAppear {
            updateTimestampLabel()
        }
    }

    // MARK: - Helpers

    private func updateTimestampLabel() {
        guard appViewModel.stationsLastUpdated.timeIntervalSince1970 > 0 else { return }
        updatedAtText = StringsService.getStringFor(key: "MapUpdatedAtLabel") + " "
            + Self.timestampFormatter.string(from: appViewModel.stationsLastUpdated)
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}
