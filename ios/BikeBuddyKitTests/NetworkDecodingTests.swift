//
//  NetworkDecodingTests.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation
import Testing
@testable import BikeBuddyKit

/// Decodes the checked-in CityBikes response that ships with the kit, so the model
/// stays in sync with the shape of data `NetworksDataService` actually receives.
@MainActor
struct NetworkDecodingTests {

    private func loadNetworksResponse() throws -> CityBikesNetworksResponse {
        let url = try #require(
            Bundle.bikeBuddyKit.url(forResource: "CityBikes_Networks_API_Response", withExtension: "json")
        )
        let data = try Data(contentsOf: url)

        return try JSONDecoder().decode(CityBikesNetworksResponse.self, from: data)
    }

    private func network(withId id: String, in response: CityBikesNetworksResponse) throws -> Network {
        return try #require(response.networks?.first { $0.id == id })
    }

    // MARK: - Response

    @Test func decodesEveryNetworkInTheResponse() throws {
        let response = try loadNetworksResponse()

        #expect(response.networks?.count == 458)
    }

    @Test func decodesNetworkTopLevelFields() throws {
        let response = try loadNetworksResponse()
        let opole = try network(withId: "opole-bike", in: response)

        #expect(opole.name == "Opole Bike")
        #expect(opole.href == "/v2/networks/opole-bike")
    }

    @Test func decodesTheCompanyList() throws {
        let response = try loadNetworksResponse()
        let opole = try network(withId: "opole-bike", in: response)

        #expect(opole.company == ["Nextbike GmbH"])
    }

    @Test func decodesNetworksThatOmitTheCompanyList() throws {
        let json = Data("""
        {"id": "no-company", "name": "No Company Bikes"}
        """.utf8)

        let decoded = try JSONDecoder().decode(Network.self, from: json)

        #expect(decoded.company == nil)
        #expect(decoded.name == "No Company Bikes")
    }

    // MARK: - Location

    @Test func decodesNetworkLocation() throws {
        let response = try loadNetworksResponse()
        let opole = try network(withId: "opole-bike", in: response)
        let location = try #require(opole.location)

        #expect(location.city == "Opole")
        #expect(location.country == "PL")
        #expect(location.latitude == 50.6645)
        #expect(location.longitude == 17.9276)
    }

    @Test func decodesCityNamesContainingDiacritics() throws {
        let response = try loadNetworksResponse()
        let wroclaw = try network(withId: "wroclawski-rower-miejski", in: response)

        #expect(wroclaw.location?.city == "Wrocław")
    }

    @Test func decodesALocationMissingItsCoordinates() throws {
        let json = Data("""
        {"id": "partial", "name": "Partial Bikes", "location": {"city": "Chicago", "country": "US"}}
        """.utf8)

        let decoded = try JSONDecoder().decode(Network.self, from: json)

        #expect(decoded.location?.city == "Chicago")
        #expect(decoded.location?.latitude == nil)
        #expect(decoded.location?.longitude == nil)
    }

    /// One network with an incomplete location used to throw and take the entire
    /// list with it, which would leave the picker empty.
    @Test func oneIncompleteLocationDoesNotFailTheWholeList() throws {
        let json = Data("""
        {"networks": [
            {"id": "partial", "name": "Partial Bikes", "location": {"city": "Chicago"}},
            {"id": "complete", "name": "Complete Bikes",
             "location": {"city": "Paris", "country": "FR", "latitude": 48.85, "longitude": 2.35}}
        ]}
        """.utf8)

        let decoded = try JSONDecoder().decode(CityBikesNetworksResponse.self, from: json)

        #expect(decoded.networks?.count == 2)
        #expect(decoded.networks?.first?.location?.country == nil)
    }

    @Test func decodesANetworkWithNoLocationAtAll() throws {
        let json = Data("""
        {"id": "locationless", "name": "Locationless Bikes"}
        """.utf8)

        let decoded = try JSONDecoder().decode(Network.self, from: json)

        #expect(decoded.location == nil)
    }

    @Test func everyDecodedNetworkHasANameAndLocation() throws {
        let response = try loadNetworksResponse()
        let networks = try #require(response.networks)

        #expect(networks.allSatisfy { $0.name != nil })
        #expect(networks.allSatisfy { $0.location != nil })
    }

    // MARK: - Round trip

    @Test func encodedNetworkCanBeDecodedAgain() throws {
        let response = try loadNetworksResponse()
        let original = try network(withId: "opole-bike", in: response)

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Network.self, from: encoded)

        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
        #expect(decoded.company == original.company)
        #expect(decoded.location?.city == original.location?.city)
        #expect(decoded.location?.country == original.location?.country)
        #expect(decoded.location?.latitude == original.location?.latitude)
    }
}
