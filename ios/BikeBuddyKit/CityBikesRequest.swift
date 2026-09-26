//
//  CityBikesRequest.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation

/// The request and response checks both data services make before decoding.
///
/// Returns the raw body rather than a decoded model: `Data` is `Sendable`, so it can
/// cross back to the calling service's actor, and each service decodes its own
/// response type there.
enum CityBikesRequest {

    /// Fetches `apiUrl` and hands back the body once it is known to be a successful
    /// JSON response.
    ///
    /// - throws: `URLError(.badURL)` for a malformed URL, `.badServerResponse` for a
    ///   non-2xx status, `.cannotParseResponse` for anything other than JSON, or
    ///   whatever the transport itself throws.
    static func data(from apiUrl: String) async throws -> Data {
        guard let url = URL(string: apiUrl) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        guard let mime = httpResponse.mimeType, mime == "application/json" else {
            throw URLError(.cannotParseResponse)
        }

        return data
    }
}
