//
//  AdaptiveLayout.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI

// MARK: - Tuning

/// Widths that keep content legible when the app is handed far more of it than a
/// phone has. Every screen that would otherwise stretch edge to edge reads from
/// here, so the column width is tuned in one place rather than per view.
enum AdaptiveLayout {

    /// Widest a single column of content is allowed to get.
    ///
    /// A station row puts the name at its leading edge and the availability counts at
    /// its trailing one. Left to fill a 13-inch iPad those two ends sit ~1300pt apart,
    /// which is more than one glance can take in — the number beside a station stops
    /// reading as belonging to it. This is about as wide as that pairing survives.
    static let contentMaxWidth: CGFloat = 700

    /// The FTU cards hold a sentence and a button, so they want to be narrower still:
    /// at column width the button alone becomes a 700pt target.
    static let onboardingCardMaxWidth: CGFloat = 460

    /// FTU artwork. The phone value is a hard cap on a 390pt-wide screen; on an iPad
    /// the same number leaves the illustration marooned in the middle of the step, so
    /// it gets room to match the space around it.
    static let onboardingArtworkMaxWidthCompact: CGFloat = 260
    static let onboardingArtworkMaxWidthRegular: CGFloat = 360

    /// Station detail's map header on a phone, unchanged.
    static let detailMapHeightCompact: CGFloat = 250

    /// The same header at regular width, as a fraction of the height it is given.
    ///
    /// A fixed height cannot win here: the screen has one short block of content, so
    /// on a 13-inch iPad in portrait any value that looks right in landscape leaves
    /// most of the page blank. Taking a share of the container instead keeps the map
    /// — the most useful thing on this screen — sized to whatever window it is in.
    static let detailMapHeightFractionRegular: CGFloat = 0.45
}

// MARK: - Content width

/// Caps width in the regular size class and leaves compact alone.
///
/// Size class rather than device idiom throughout: an iPad window dragged narrow in
/// Split View or Stage Manager is compact, and phone layout is the right layout for
/// it. Keying off the idiom would leave those windows with a column too wide to fit.
private struct ContentWidthModifier: ViewModifier {

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let maxWidth: CGFloat

    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            content.frame(maxWidth: maxWidth)
        } else {
            content
        }
    }
}

/// The same cap for a List, which needs the colour it draws behind its rows carried
/// out to the window edges as well. Without that the inset column reads as a panel
/// floating on a differently-shaded background rather than as the screen itself.
private struct ListWidthModifier: ViewModifier {

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let maxWidth: CGFloat
    let background: Color

    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            content
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity)
                .background(background.ignoresSafeArea())
        } else {
            content
        }
    }
}

extension View {

    /// Centres this view in a column no wider than `maxWidth` when there is room to
    /// spare, and does nothing at compact width.
    func adaptiveContentWidth(_ maxWidth: CGFloat = AdaptiveLayout.contentMaxWidth) -> some View {
        modifier(ContentWidthModifier(maxWidth: maxWidth))
    }

    /// `adaptiveContentWidth` for a List: also fills the freed space with the list's
    /// own background colour so the two meet invisibly.
    ///
    /// Pass the colour the list style actually draws — `.systemGroupedBackground` for
    /// grouped and inset-grouped lists, `.systemBackground` for plain ones.
    func adaptiveListWidth(
        _ maxWidth: CGFloat = AdaptiveLayout.contentMaxWidth,
        background: Color = Color(.systemGroupedBackground)
    ) -> some View {
        modifier(ListWidthModifier(maxWidth: maxWidth, background: background))
    }
}
