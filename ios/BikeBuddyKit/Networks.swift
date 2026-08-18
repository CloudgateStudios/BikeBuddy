//
//  Networks.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/25/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

@MainActor
public final class Networks {
    public static let sharedInstance = Networks()
    
    public var list = [Network]() {
        didSet {
            self.lastUpdated = NSDate()

            setupNetworksBySection()
        }
    }
    
    public private(set) var lastUpdated = NSDate()
    public private(set) var networksBySection = [(key: String, value: [Network])]()
    
    private init() {
    }
    
    private func setupNetworksBySection() {
        var bySectionWorkingCopy = [String: [Network]]()
        let sortedNetworkList = Networks.sortedByName(self.list)
        
        for item in sortedNetworkList {
            // `first` covers both a missing name and an empty one. Subscripting
            // startIndex instead would trap on "", taking down the whole picker
            // because this runs from the didSet on `list`.
            if let firstCharacter = item.name?.first {
                let firstLetter = String(firstCharacter).uppercased()

                if bySectionWorkingCopy[firstLetter] != nil {
                    var currentItemsInSection = bySectionWorkingCopy[firstLetter]
                    currentItemsInSection?.append(item)
                    bySectionWorkingCopy[firstLetter] = currentItemsInSection
                } else {
                    bySectionWorkingCopy[firstLetter] = [item]
                }

            }
        }
        
        let workingcopy = bySectionWorkingCopy.sorted { $0.key < $1.key }
        self.networksBySection = workingcopy
    }
 
    public static func getSortedByNetworkName() -> [Network] {
        return sortedByName(self.sharedInstance.list)
    }

    /// Sorts by name. Networks without a name sort to the front rather than crashing.
    private static func sortedByName(_ networks: [Network]) -> [Network] {
        return networks.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
    
    /**
     Searches the network list for a match on the network name or its location. The location is
     matched on the city, the raw country code and the localized country name so that what is
     displayed in the picker is also what can be searched for.

     - parameter searchText: The text the user typed in. Matching ignores case and diacritics.

     - returns: The matching networks sorted by name.
     */
    public static func searchThroughList(searchText: String) -> [Network] {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespaces)

        if trimmedSearchText.isEmpty {
            return getSortedByNetworkName()
        }

        let returnArray = self.sharedInstance.list.filter { item in
            searchableStrings(for: item).contains { $0.matches(trimmedSearchText) }
        }

        return sortedByName(returnArray)
    }

    private static func searchableStrings(for network: Network) -> [String] {
        var values = [String]()

        if let name = network.name {
            values.append(name)
        }

        if let city = network.location?.city {
            values.append(city)
        }

        if let country = network.location?.country {
            values.append(country)
            values.append(CountryCleanupService.sharedInstance.mapCountryCodeToString(countryCode: country))
        }

        return values
    }

}

private extension String {
    /// Normalizes for searching by folding case and accents.
    ///
    /// `.diacriticInsensitive` alone only decomposes an accent from its base letter, so it
    /// leaves letters that carry a stroke or slash untouched - "Wrocław" stays "wrocław" and
    /// would never match a typed "Wroclaw". The Latin-ASCII transform handles those (ł, ø, đ)
    /// and passes non-Latin scripts through unchanged, so those still match themselves.
    var searchNormalized: String {
        let transliterated = applyingTransform(StringTransform("Latin-ASCII"), reverse: false) ?? self

        return transliterated.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }

    func matches(_ searchText: String) -> Bool {
        searchNormalized.contains(searchText.searchNormalized)
    }

}
