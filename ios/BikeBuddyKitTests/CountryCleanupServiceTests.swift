//
//  CountryCleanupServiceTests.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Testing
@testable import BikeBuddyKit

/// The country mapping is what the network picker displays under each network, and
/// since the search now matches on it too, it is worth pinning down directly.
@MainActor
struct CountryCleanupServiceTests {

    @Test func mapsKnownCountryCodeToAFullName() {
        let mapped = CountryCleanupService.sharedInstance.mapCountryCodeToString(countryCode: "US")

        // The exact string is locale dependent, so assert that it was expanded
        // rather than hard-coding one locale's wording.
        #expect(mapped != "US")
        #expect(mapped.count > 2)
    }

    @Test func mapsSeveralCountryCodesToDistinctNames() {
        let service = CountryCleanupService.sharedInstance

        let unitedStates = service.mapCountryCodeToString(countryCode: "US")
        let france = service.mapCountryCodeToString(countryCode: "FR")
        let poland = service.mapCountryCodeToString(countryCode: "PL")

        #expect(Set([unitedStates, france, poland]).count == 3)
    }

    @Test func returnsTheOriginalValueForAnUnknownCode() {
        let mapped = CountryCleanupService.sharedInstance.mapCountryCodeToString(countryCode: "ZZ")

        #expect(mapped == "ZZ")
    }

    @Test func returnsAnEmptyStringForAnEmptyCode() {
        let mapped = CountryCleanupService.sharedInstance.mapCountryCodeToString(countryCode: "")

        #expect(mapped.isEmpty)
    }
}
