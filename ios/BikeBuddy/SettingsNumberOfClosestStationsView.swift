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
        .adaptiveListWidth()
        .navigationTitle(Text("SettingsSelectNumOfClosestStationsNavBarTitle", bundle: .bikeBuddyKit))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func selectOption(_ option: Int) {
        appViewModel.selectNumberOfClosestStations(option)
        dismiss()
    }
}
