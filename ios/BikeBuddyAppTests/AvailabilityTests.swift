//
//  AvailabilityTests.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import Testing
import BikeBuddyKit
@testable import BikeBuddy

/// One rule colours every bike and dock count in the app, so it is pinned here
/// rather than in each of the three views that draw one.
struct AvailabilityTests {

    @Test func anEmptyCountIsRed() {
        #expect(Availability.color(for: 0) == .red)
    }

    @Test(arguments: [1, 2])
    func aLowCountIsOrange(count: Int) {
        #expect(Availability.color(for: count) == .orange)
    }

    @Test(arguments: [3, 25])
    func aHealthyCountIsPlain(count: Int) {
        #expect(Availability.color(for: count) == .primary)
    }

    /// The feed's "not reported" sentinel is not an empty station, so it must not
    /// read as one.
    @Test func anUnknownCountIsNotFlagged() {
        #expect(Availability.color(for: Station.unknownCount) == .primary)
    }
}
