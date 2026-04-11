//
//  SettingsAboutView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Replaces SettingsAboutTableViewController + SettingsAboutPrivacyPolicyTableViewController.
struct SettingsAboutView: View {

    var body: some View {
        List {
            // MARK: App info
            Section {
                Text(versionString)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }

            // MARK: Data source
            Section {
                Text(StringsService.getStringFor(key: "SettingsAboutCityBikesLineOne"))
                Text(StringsService.getStringFor(key: "SettingsAboutCityBikesLineTwo"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // MARK: Privacy policy
            Section {
                if let privacyURL = URL(string: Constants.ExtneralURL.PrivacyPolicyURL) {
                    Link("Privacy Policy", destination: privacyURL)
                        .foregroundStyle(.primary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(StringsService.getStringFor(key: "SettingsAboutNavBarTitle"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenSettingsAbout)
        }
    }

    // MARK: - Helpers

    private var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
        return version == build ? "Version \(version)" : "Version \(version) (\(build))"
    }
}
