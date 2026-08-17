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
                Text("SettingsAboutCityBikesLineOne", bundle: .bikeBuddyKit)
                Text("SettingsAboutCityBikesLineTwo", bundle: .bikeBuddyKit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // MARK: Privacy policy
            Section {
                if let privacyURL = URL(string: Constants.ExtneralURL.PrivacyPolicyURL) {
                    Link(destination: privacyURL) {
                        Text("SettingsAboutPrivacyPolicyLabel", bundle: .bikeBuddyKit)
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text("SettingsAboutNavBarTitle", bundle: .bikeBuddyKit))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenSettingsAbout)
        }
    }

    // MARK: - Helpers

    private var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""

        if version == build {
            return String(format: String(localized: "SettingsAboutVersionLabel", bundle: .bikeBuddyKit), version)
        }

        return String(format: String(localized: "SettingsAboutVersionWithBuildLabel", bundle: .bikeBuddyKit), version, build)
    }
}
