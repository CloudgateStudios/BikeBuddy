//
//  StationSelectionCard.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

// MARK: - Station selection card

/// Glass card that slides up when a station is selected.
///
/// This is the station detail on iPad: with the map already filling the screen behind
/// it, a separate detail screen would only repeat what is visible and cover it up. So
/// the card carries the counts and both actions, and `onDismiss` puts it away.
struct StationSelectionCard: View {

    let station: Station
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            // Name + distance
            VStack(alignment: .leading, spacing: 4) {
                Text(station.stationName)
                    .font(.headline)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if station.distanceFromUser > 0 {
                    Text(station.approximateDistanceAwayFromUser + " " + String(localized: "GeneralAwayLabel", bundle: .bikeBuddyKit))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !station.streetAddress.isEmpty {
                    Text(station.streetAddress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Bikes count
            availabilityPill(
                count: station.availableBikes,
                icon: "bicycle",
                color: bikesColor
            )

            // Docks count
            availabilityPill(
                count: station.availableDocks,
                icon: "arrow.down.to.line",
                color: .primary
            )

            Button {
                station.openInMaps()
            } label: {
                Text("StationDetailDirectionsButton", bundle: .bikeBuddyKit)
            }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .hoverEffect(.lift)

            ShareLink(
                item: station.shareStringDescription,
                subject: Text(station.stationName)
            ) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .medium))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .hoverEffect(.lift)
            .accessibilityLabel(Text("StationDetailShareButton", bundle: .bikeBuddyKit))

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    // The circle reads better small, but the target cannot be: 28pt
                    // is well under the 44pt minimum, so the glyph keeps its size
                    // inside a frame that does not.
                    .frame(width: 28, height: 28)
                    .background(Color(.tertiarySystemFill), in: Circle())
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .hoverEffect(.lift)
            .accessibilityLabel(Text("MapDeselectStationAccessibilityLabel", bundle: .bikeBuddyKit))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func availabilityPill(count: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Group {
                if count < 0 {
                    Text(verbatim: "—")
                } else {
                    Text(count, format: .number)
                }
            }
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
                .monospacedDigit()
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 34)
    }

    private var bikesColor: Color {
        switch station.availableBikes {
        case 0:     .red
        case 1...2: .orange
        default:    .primary
        }
    }
}
