//
//  NetworksTests.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation
import Testing
@testable import BikeBuddyKit

/// `Networks` is a `@MainActor` singleton, so every test here mutates the same shared
/// `list`. The suite is serialized to keep those mutations from overlapping.
@MainActor
@Suite(.serialized)
struct NetworksTests {

    // MARK: - Test data

    private func makeNetwork(id: String, name: String?, city: String?, country: String?) -> Network {
        let network = Network()!

        network.id = id
        network.name = name

        if city != nil || country != nil {
            let location = Location()!
            location.city = city
            location.country = country
            network.location = location
        }

        return network
    }

    /// A small stand-in for the real API list. Deliberately mixes countries and
    /// diacritics so search can be exercised without hitting the network.
    private func loadTestNetworks() {
        Networks.sharedInstance.list = [
            makeNetwork(id: "divvy", name: "Divvy", city: "Chicago", country: "US"),
            makeNetwork(id: "nice-ride", name: "Nice Ride", city: "Minneapolis", country: "US"),
            makeNetwork(id: "bay-area", name: "Bay Area Bike Share", city: "San Francisco", country: "US"),
            makeNetwork(id: "velib", name: "Vélib'", city: "Paris", country: "FR"),
            makeNetwork(id: "malmo", name: "Malmö by bike", city: "Malmö", country: "SE"),
            makeNetwork(id: "opole", name: "Opole Bike", city: "Opole", country: "PL")
        ]
    }

    private func names(_ networks: [Network]) -> [String] {
        return networks.map { $0.name ?? "" }
    }

    // MARK: - Search: network name

    @Test func searchMatchesNetworkName() {
        loadTestNetworks()

        #expect(names(Networks.searchThroughList(searchText: "Divvy")) == ["Divvy"])
    }

    @Test func searchMatchesPartialNetworkName() {
        loadTestNetworks()

        let expected = ["Bay Area Bike Share", "Malmö by bike", "Opole Bike"]

        #expect(names(Networks.searchThroughList(searchText: "Bike")) == expected)
    }

    @Test func searchIgnoresCaseInNetworkName() {
        loadTestNetworks()

        #expect(names(Networks.searchThroughList(searchText: "dIvVy")) == ["Divvy"])
    }

    // MARK: - Search: location

    @Test func searchMatchesCity() {
        loadTestNetworks()

        #expect(names(Networks.searchThroughList(searchText: "Chicago")) == ["Divvy"])
    }

    @Test func searchIgnoresCaseInCity() {
        loadTestNetworks()

        #expect(names(Networks.searchThroughList(searchText: "minneapolis")) == ["Nice Ride"])
    }

    @Test func searchMatchesCountryCode() {
        loadTestNetworks()

        #expect(names(Networks.searchThroughList(searchText: "PL")) == ["Opole Bike"])
    }

    /// Country codes are only two characters, so they can also turn up inside a city
    /// or network name. Matching stays a plain substring search in that case.
    @Test func searchOnAShortCodeAlsoMatchesTextThatContainsIt() {
        loadTestNetworks()

        // "FR" is France's code, but it is also inside "San Francisco".
        #expect(names(Networks.searchThroughList(searchText: "FR")) == ["Bay Area Bike Share", "Vélib'"])
    }

    @Test func searchMatchesLocalizedCountryName() {
        loadTestNetworks()

        // Resolved through the same service the picker displays, so the assertion
        // holds regardless of the device locale the tests run under.
        let unitedStates = CountryCleanupService.sharedInstance.mapCountryCodeToString(countryCode: "US")

        #expect(names(Networks.searchThroughList(searchText: unitedStates)) == ["Bay Area Bike Share", "Divvy", "Nice Ride"])
    }

    // MARK: - Search: diacritics

    @Test func searchIgnoresDiacriticsInNetworkName() {
        loadTestNetworks()

        #expect(names(Networks.searchThroughList(searchText: "velib")) == ["Vélib'"])
    }

    @Test func searchIgnoresDiacriticsInCity() {
        loadTestNetworks()

        #expect(names(Networks.searchThroughList(searchText: "malmo")) == ["Malmö by bike"])
    }

    /// "ł" carries a stroke rather than a combining accent, so it needs more than
    /// plain diacritic-insensitive folding to match a typed "l".
    @Test func searchIgnoresStrokedLatinLetters() {
        Networks.sharedInstance.list = [
            makeNetwork(id: "wroclaw", name: "Rower Miejski", city: "Wrocław", country: "PL"),
            makeNetwork(id: "copenhagen", name: "Bycyklen", city: "Ørestad", country: "DK")
        ]

        #expect(names(Networks.searchThroughList(searchText: "Wroclaw")) == ["Rower Miejski"])
        #expect(names(Networks.searchThroughList(searchText: "orestad")) == ["Bycyklen"])
    }

    @Test func searchMatchesWhenSearchTextCarriesTheDiacritic() {
        loadTestNetworks()

        #expect(names(Networks.searchThroughList(searchText: "Malmö")) == ["Malmö by bike"])
    }

    // MARK: - Search: input handling

    @Test func searchTrimsSurroundingWhitespace() {
        loadTestNetworks()

        #expect(names(Networks.searchThroughList(searchText: "  Chicago  ")) == ["Divvy"])
    }

    @Test func emptySearchReturnsEverythingSortedByName() {
        loadTestNetworks()

        let expected = ["Bay Area Bike Share", "Divvy", "Malmö by bike", "Nice Ride", "Opole Bike", "Vélib'"]

        #expect(names(Networks.searchThroughList(searchText: "")) == expected)
    }

    @Test func whitespaceOnlySearchReturnsEverything() {
        loadTestNetworks()

        #expect(Networks.searchThroughList(searchText: "   ").count == 6)
    }

    @Test func searchWithNoMatchesReturnsEmpty() {
        loadTestNetworks()

        #expect(Networks.searchThroughList(searchText: "Nonexistent City").isEmpty)
    }

    @Test func searchResultsAreSortedByName() {
        loadTestNetworks()

        let unitedStates = CountryCleanupService.sharedInstance.mapCountryCodeToString(countryCode: "US")
        let results = names(Networks.searchThroughList(searchText: unitedStates))

        #expect(results == results.sorted())
    }

    // MARK: - Search: incomplete data

    @Test func searchSkipsNetworksMissingALocation() {
        Networks.sharedInstance.list = [
            makeNetwork(id: "no-location", name: "Ghost Bikes", city: nil, country: nil)
        ]

        #expect(names(Networks.searchThroughList(searchText: "Ghost")) == ["Ghost Bikes"])
        #expect(Networks.searchThroughList(searchText: "Chicago").isEmpty)
    }

    @Test func searchMatchesLocationOnNetworksMissingAName() {
        Networks.sharedInstance.list = [
            makeNetwork(id: "no-name", name: nil, city: "Chicago", country: "US")
        ]

        #expect(Networks.searchThroughList(searchText: "Chicago").count == 1)
    }

    @Test func searchOnEmptyListReturnsEmpty() {
        Networks.sharedInstance.list = []

        #expect(Networks.searchThroughList(searchText: "Divvy").isEmpty)
    }

    // MARK: - Sorting

    @Test func getSortedByNetworkNameSortsAlphabetically() {
        loadTestNetworks()

        let expected = ["Bay Area Bike Share", "Divvy", "Malmö by bike", "Nice Ride", "Opole Bike", "Vélib'"]

        #expect(names(Networks.getSortedByNetworkName()) == expected)
    }

    @Test func sortingToleratesNetworksMissingAName() {
        Networks.sharedInstance.list = [
            makeNetwork(id: "divvy", name: "Divvy", city: "Chicago", country: "US"),
            makeNetwork(id: "no-name", name: nil, city: "Chicago", country: "US")
        ]

        #expect(Networks.getSortedByNetworkName().count == 2)
    }

    // MARK: - Sections

    @Test func sectionsAreKeyedByUppercasedFirstLetter() {
        loadTestNetworks()

        let sections = Networks.sharedInstance.networksBySection

        #expect(sections.map { $0.key } == ["B", "D", "M", "N", "O", "V"])
    }

    @Test func sectionsGroupNetworksSharingAFirstLetter() {
        Networks.sharedInstance.list = [
            makeNetwork(id: "divvy", name: "Divvy", city: "Chicago", country: "US"),
            makeNetwork(id: "decobike", name: "Decobike San Diego", city: "San Diego", country: "US"),
            makeNetwork(id: "opole", name: "Opole Bike", city: "Opole", country: "PL")
        ]

        let sections = Networks.sharedInstance.networksBySection

        #expect(sections.count == 2)
        #expect(sections.first?.key == "D")
        #expect(names(sections.first?.value ?? []) == ["Decobike San Diego", "Divvy"])
    }

    @Test func sectionsExcludeNetworksMissingAName() {
        Networks.sharedInstance.list = [
            makeNetwork(id: "divvy", name: "Divvy", city: "Chicago", country: "US"),
            makeNetwork(id: "no-name", name: nil, city: "Chicago", country: "US")
        ]

        let sections = Networks.sharedInstance.networksBySection

        #expect(sections.count == 1)
        #expect(sections.first?.value.count == 1)
    }

    @Test func settingListRebuildsSections() {
        loadTestNetworks()
        #expect(Networks.sharedInstance.networksBySection.count == 6)

        Networks.sharedInstance.list = []

        #expect(Networks.sharedInstance.networksBySection.isEmpty)
    }

    // MARK: - Against the real API fixture

    /// Lives in this suite rather than `NetworkDecodingTests` because it mutates the
    /// shared `list`, and only this suite is serialized against that.
    @Test func decodedNetworksCanBeSearchedByCity() throws {
        let url = try #require(
            Bundle.bikeBuddyKit.url(forResource: "CityBikes_Networks_API_Response", withExtension: "json")
        )
        let response = try JSONDecoder().decode(CityBikesNetworksResponse.self, from: Data(contentsOf: url))
        Networks.sharedInstance.list = try #require(response.networks)

        let byCity = Networks.searchThroughList(searchText: "Wrocław")
        let byDiacriticFreeCity = Networks.searchThroughList(searchText: "Wroclaw")

        #expect(byCity.contains { $0.id == "wroclawski-rower-miejski" })
        #expect(byDiacriticFreeCity.contains { $0.id == "wroclawski-rower-miejski" })
    }

    @Test func settingListUpdatesLastUpdated() {
        Networks.sharedInstance.list = []
        let before = Networks.sharedInstance.lastUpdated

        loadTestNetworks()

        #expect(Networks.sharedInstance.lastUpdated.timeIntervalSince1970 >= before.timeIntervalSince1970)
    }
}
