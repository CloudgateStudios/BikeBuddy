//
//  SettingsNumberOfClosestStationsView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Replaces SettingsNumberOfClosestStationsTableViewController.
struct SettingsNumberOfClosestStationsView: View {

    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.dismiss) private var dismiss

    private let options = [5, 10, 15, 20]

    var body: some View {
        List {
            ForEach(options, id: \.self) { option in
                Button {
                    selectOption(option)
                } label: {
                    HStack {
                        Text(String(option))
                            .foregroundStyle(.primary)
                        Spacer()
                        if option == appViewModel.numberOfClosestStations {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color("BikeBuddyBlue"))
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text("SettingsSelectNumOfClosestStationsNavBarTitle", bundle: .bikeBuddyKit))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenSettingsNumberOfClosestStations)
        }
    }

    private func selectOption(_ option: Int) {
        let oldValue = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.NumberOfClosestStations)
        let analyticAttr = [
            Constants.AnalyticEventDetail.OldNumber: oldValue,
            Constants.AnalyticEventDetail.NewNumber: String(option)
        ]
        AnalyticsService.sharedInstance.pegUserAction(
            eventName: Constants.AnalyticEvent.SelectNewNumberOfClosestStations,
            customAttributes: analyticAttr as [String: AnyObject]
        )
        appViewModel.selectNumberOfClosestStations(option)
        dismiss()
    }
}
