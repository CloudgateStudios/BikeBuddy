//
//  AvailabilityCount.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI

// MARK: - Colour

/// How a bike or dock count is coloured, wherever one is drawn.
///
/// Docks get the same treatment as bikes. An empty dock is as much a dead end as an
/// empty rack — it is where the user cannot return the bike they are riding — and
/// the list, the map card and the detail screen used to disagree about whether that
/// was worth flagging.
enum Availability {

    static func color(for count: Int) -> Color {
        switch count {
        case 0:     .red
        case 1...2: .orange
        default:    .primary
        }
    }
}

// MARK: - Count

/// A bike or dock count in its availability colour, or a dash when the feed did not
/// report one.
///
/// Size is the caller's: the row, the map card and the detail screen each set their
/// own font around this.
struct AvailabilityCount: View {

    let count: Int

    var body: some View {
        Group {
            if count < 0 {
                Text(verbatim: "—")
            } else {
                Text(count, format: .number)
            }
        }
        .foregroundStyle(Availability.color(for: count))
        .monospacedDigit()
    }
}
