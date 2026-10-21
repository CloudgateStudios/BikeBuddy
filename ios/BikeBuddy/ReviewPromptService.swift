//
//  ReviewPromptService.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation
import BikeBuddyKit

/// Decides when the system review prompt is worth asking for.
///
/// iOS shows the prompt at most three times a year per user, so each request is
/// spent only on someone the app has demonstrably helped: they have asked for
/// directions or shared a station several times, on more than one day, and have had
/// the app a few days. The ask itself waits until they come back after asking for
/// directions — the moment the app has just done its job — rather than interrupting
/// the hand-off to Maps.
///
/// Storage is injected so tests can use a throwaway suite instead of the shared app
/// group the real settings live in.
@MainActor
final class ReviewPromptService {

    // MARK: - Thresholds

    static let minimumSignificantActions = 3
    static let minimumActiveDays = 2
    static let minimumDaysSinceFirstSeen = 3

    // MARK: - Dependencies

    private let defaults: UserDefaults
    private let now: () -> Date
    private let calendar: Calendar

    /// Set by a Directions request, armed once the app actually leaves for Maps.
    /// Held in memory only: a relaunch is not a return from the trip that set it.
    private var awaitingReturnFromDirections = false
    private var leftAppForDirections = false

    init(
        defaults: UserDefaults = UserDefaults(suiteName: Constants.SettingsGeneral.ShareGroupName)!,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.defaults = defaults
        self.now = now
        self.calendar = calendar

        // Existing users have no install date to go on, so the clock starts the first
        // time this runs rather than at install.
        if defaults.object(forKey: Constants.SettingsKey.reviewFirstSeenDate.rawValue) == nil {
            defaults.set(now(), forKey: Constants.SettingsKey.reviewFirstSeenDate.rawValue)
        }
    }

    // MARK: - Engagement

    /// Counts an action that shows the app was useful: Directions or Share.
    func recordSignificantAction() {
        let actions = defaults.integer(forKey: Constants.SettingsKey.reviewSignificantActionCount.rawValue)
        defaults.set(actions + 1, forKey: Constants.SettingsKey.reviewSignificantActionCount.rawValue)

        let today = calendar.startOfDay(for: now())
        let lastDay = defaults.object(forKey: Constants.SettingsKey.reviewLastActiveDay.rawValue) as? Date
        if lastDay != today {
            let days = defaults.integer(forKey: Constants.SettingsKey.reviewActiveDayCount.rawValue)
            defaults.set(days + 1, forKey: Constants.SettingsKey.reviewActiveDayCount.rawValue)
            defaults.set(today, forKey: Constants.SettingsKey.reviewLastActiveDay.rawValue)
        }
    }

    func recordDirectionsRequested() {
        recordSignificantAction()
        awaitingReturnFromDirections = true
        leftAppForDirections = false
    }

    /// Only a trip that actually left the app counts as one to come back from.
    func appDidEnterBackground() {
        if awaitingReturnFromDirections {
            leftAppForDirections = true
        }
    }

    // MARK: - Prompting

    /// Whether to ask now, on the app becoming active again. A yes is recorded
    /// against this version, so the caller must go on to make the request.
    ///
    /// Any return clears the pending trip whether or not it prompts: one Directions
    /// tap earns one check, not a standing claim on every later launch.
    func consumePromptIfDue(appVersion: String, hasLoadError: Bool) -> Bool {
        defer {
            awaitingReturnFromDirections = false
            leftAppForDirections = false
        }
        guard leftAppForDirections, !hasLoadError, isEligible(appVersion: appVersion) else { return false }

        defaults.set(appVersion, forKey: Constants.SettingsKey.reviewLastPromptedVersion.rawValue)
        return true
    }

    func isEligible(appVersion: String) -> Bool {
        let actions = defaults.integer(forKey: Constants.SettingsKey.reviewSignificantActionCount.rawValue)
        let days = defaults.integer(forKey: Constants.SettingsKey.reviewActiveDayCount.rawValue)
        let lastVersion = defaults.string(forKey: Constants.SettingsKey.reviewLastPromptedVersion.rawValue)

        guard actions >= Self.minimumSignificantActions,
              days >= Self.minimumActiveDays,
              lastVersion != appVersion,
              let firstSeen = defaults.object(forKey: Constants.SettingsKey.reviewFirstSeenDate.rawValue) as? Date,
              let daysSinceFirstSeen = calendar.dateComponents([.day], from: firstSeen, to: now()).day
        else { return false }

        return daysSinceFirstSeen >= Self.minimumDaysSinceFirstSeen
    }
}
