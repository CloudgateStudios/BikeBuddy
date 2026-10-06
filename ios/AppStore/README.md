# App Store screenshots

Composed screenshots for the three slots this listing fills — iPhone, iPad and
iPhone Duo.
App Store Connect keeps a separate set per device family, so "one size scales down to
the rest" holds *within* a family and not across them.

    captures/<device>/<theme>/   raw captures, straight off the simulator
    screenshots/6.9/street/      what the iPhone slot wants
    screenshots/6.9/dusk/        the dark alternative
    screenshots/13/…             the iPad set
    screenshots/duo/…            the iPhone Duo set, folded
    screenshots/duo-inner/…      the iPhone Duo set, unfolded
    compose.py                   puts one inside the other
    build/                       generated HTML, throwaway (gitignored)

`screenshots/` is derived from `captures/` and rebuilds in seconds, but it is
committed anyway: it is the record of exactly what went to Apple. `captures/` is
committed for the same reason and so composing works from a clean checkout without
booting a simulator. PNGs do not delta-compress, so a regenerated set is a fresh few
MB in history every time — worth re-committing when a submission changes, not on
every experiment.

Both themes are built from the same captures, light and dark. Upload one set — they
are alternatives, not a sequence. `street` is the intended one.

Four screenshots, ordered as they appear on the listing:

    01-stations   the closest stations, with bikes and docks
    02-map        the whole network, clustered
    03-detail     one station: counts and the walk to it
    04-networks   the picker — the coverage claim, on screen

The stations list leads because it is the question the app answers, and because the
first screenshot is the one that shows up in search results. Coverage goes last
because it is the reason to keep the app rather than the reason to open it.

## Regenerating

```
python3 ios/AppStore/compose.py                             # every size and theme
python3 ios/AppStore/compose.py --size 6.9 --theme street   # just the one to upload
python3 ios/AppStore/compose.py --size 13                   # the iPad set
python3 ios/AppStore/compose.py --size duo                  # the iPhone Duo, folded
python3 ios/AppStore/compose.py --size duo-inner            # the iPhone Duo, unfolded
```

Reads `captures/`, writes `screenshots/<size>/<theme>/`. One folder per upload, so
submitting is a single drag. `compose.py` skips any spec whose capture is missing
rather than failing the run.

Rendering is headless Chrome at an exact window size, so the output is pixel-exact
rather than scaled — no image library and nothing to install beyond Chrome.

### How the sizes work

A **family** owns a stage, a device frame and a type scale; a **size** is one App
Store Connect slot within a family.

    phone   stage 1320 x 2868   →  slot 6.9"
    pad     stage 2064 x 2752   →  slot 13"
    duo         stage 1398 x 2034   →  slot iPhone Duo (outer display)
    duo-inner   stage 2853 x 2007   →  slot iPhone Duo (inner display, landscape)

Within a family the design is authored once and scaled to the target slot by a single
CSS transform on the whole stage, *before* rasterising. So each size is rendered at
its own resolution rather than resampled from a larger PNG — radii, shadows, masks
and type all scale together and nothing softens. Adding a slot to an existing family
(6.5", say) is one entry in `SIZES` and no new captures.

**Why iPad is not just another entry in `SIZES`.** The scale-by-width trick works
because every iPhone slot is within a hair of 0.46:1, so one canvas covers all of
them. A 13" iPad is 0.75:1 — scaling the phone stage to 2064 wide would put its foot
far below the bottom edge, and the frame in the middle of it is phone-shaped anyway.
Hence `FAMILIES`. What the two share is the part that makes them look like one app:
the ground, the lighting, the palette and the type pairing. What they do not share is
any measurement.

**Why the Duo is a family too.** Its cover display is 0.69:1, which is neither of
the above, and its corners are asymmetric — 8pt on the spine edge, 59pt on the other —
so it needs a frame that is not a rounded rectangle. `spiner` and `spinescr` carry the
spine-side radii; a family that leaves them out gets one radius all round.

App Store Connect's Duo slot accepts either display, in either orientation:
1398 x 2034 (outer) or 2007 x 2853 (inner). Both are here, as two families, because
they are two layouts and not two sizes of one. The cover is compact width and gets
the sheet; the inner display is regular width and gets the split view, so `duo-inner`
uses the iPad's copy and is composed in landscape, which is how the unfolded device
is held.

Every slot is captured native — an iPhone 17 Pro Max screen is exactly 1320 x 2868,
an iPad Pro 13-inch is exactly 2064 x 2752, and the Duo is exactly 1398 x 2034
folded and 2853 x 2007 unfolded — so nothing inside a device frame is ever upscaled.

## Header and search results

App Store Connect's *Header and Search Results* tab takes creative assets, which are
separate from screenshots and have their own sizes:

    creative/street/header.png   3840 x 1646   product page header (21:9)
    creative/street/search.png   3840 x 2560   search results (3:2)
    creative/dusk/…              the dark alternatives

```
python3 ios/AppStore/creative.py                      # both assets, both themes
python3 ios/AppStore/creative.py --asset header --theme street
```

`creative.py` borrows the themes from `compose.py` and the iPhone stations capture, so
these match the screenshots under them. The difference is that App Store Connect crops
a creative asset differently per device and orientation, so nothing that matters is
placed near an edge: the headline and the device are held inside the middle of the
frame (`safe`), and only the ground runs to the edges. Check the result with the
Preview button on that tab before submitting — Apple publishes the sizes but not the
crop, so the safe area here is a judgment, not a spec.

The header is too short to stand a phone up in, so the phone runs off the top and
bottom and the strip shows the middle of the screen. Search shows the whole phone and
carries a supporting line, because that is where someone is deciding what the app is.

There is also a 16:9 "universal" size that serves both placements from one image. It
is not used: the two placements want different compositions.

## Recapturing

```
cd ios
bundle exec fastlane screenshots
```

That runs `snapshot` twice (light, then dark) across all three capture devices, then
copies the numbered PNGs into `AppStore/captures/`. To re-collect from an existing
snapshot run without re-capturing: `bundle exec fastlane collect_captures`.

### The Duo's inner display

`fastlane screenshots` cannot capture it. XCUITest photographs and taps the cover
display, and the run folds the simulator shut. Instead:

```
ios/AppStore/capture-duo-inner.sh
```

Unfold the simulator by hand first, in landscape — nothing in simctl does it. The
script builds the app, launches it once per screen with `-ScreenshotScene
detail|map|networks` so it opens there without being tapped, and photographs display 3
with `simctl io screenshot`. The scenes are read only when `UI_TESTING_SCREENSHOTS` is
set, so an ordinary launch ignores the argument.

Everything the shots need is arranged by the app itself under the
`UI_TESTING_SCREENSHOTS` flag, so there is no tapping and no live network:

- **Stations, location and distances.** `ScreenshotMockData` supplies a fixed vantage
  on 8th Ave near W 42 St and the 64 real Citi Bike stations nearest it, at their real
  coordinates with invented counts. `LocationManager` stands CoreLocation down and
  reports that coordinate instead, because the simulator grants nothing under
  `snapshot` — without it the list captures its "Not Sorted by Distance" state, which
  is an honest picture of a denied permission and the wrong thing to put on a listing.
- **The clock.** `stationsLastUpdated` is pinned to 9:41 so the map's "Updated at"
  agrees with the status bar `override_status_bar` paints. Two different times in one
  frame reads as sloppy even when nobody can say why.
- **The networks list.** Seeded too, so `04-networks` needs no network either — which
  is what "network-independent" has to mean for the one screen whose whole job is a
  downloaded list.

Only the availability counts are invented. Station names, coordinates and the network
list are real, so the screenshots cannot drift into showing geography that does not
exist.

## Design

Both themes are the same composition lit differently: one light source above and
behind the device, faint bike-lane markings low on the ground, a contact shadow where
the device meets it, and the corners pulled down so the ground reads as lit from one
place rather than printed flat.

**street** puts the light-mode app on pale concrete. This is the one that makes the
device an object: white screen and dark bezel against mid-grey separate hard, where a
dark screen on a dark ground would lean entirely on the glow and the bezel to find
its edges.

**dusk** puts the dark-mode app on warm near-black under a streetlight.

### Why the accent changes between them

The app's `#3CA3DC` manages just **1.74:1** on pale concrete — a mid-value blue on a
mid-value grey — so the headline's second line would dissolve at thumbnail size,
which is how these get judged in search results.

So the street theme keeps the hue and drops the lightness to `#0F4C6B`, which
measures **5.73:1**. Still the brand, now legible.

Measured, not eyeballed. On `#CFCBC4`: ink `#23262B` at 9.39:1 for the headline,
accent `#0F4C6B` at 5.73:1 for the second line, `#4E5560` at 4.65:1 for the
supporting line. All clear WCAG AA with room to spare.

On `dusk`'s `#0A0B0D` the brand colour needs no help: ink 17.37:1, accent `#3CA3DC`
at 7.00:1, supporting line 5.34:1.

### Type

DIN Condensed Bold for the headline. DIN 1451 is literally the German road-signage
typeface — it is what street name plates and cycle route signs are set in, so it is
the register the subject already speaks. SF Pro for the supporting line, matching the
app itself; SF Mono for the eyebrow, tracked out like a route marker. All three ship
with macOS, so there is nothing to download and no webfont that can silently fall
back to Helvetica.

The second line of every headline carries the accent. One screen doing that reads as
a screen shouting; all of them doing it reads as a system.

### Cropping

Three of the four are shown whole. **iPad `03-detail` is cropped**, because that
screen has genuine empty space in it: one station's detail does not fill 1376pt of
portrait iPad, so the foot of it is white. The crop takes the part that carries the
screen and dissolves the rest into the ground, rather than ending on a bezel with a
slab of nothing above it.

What it must not do is imply content is there that is not — hence a dissolve rather
than a hard cut, and hence the copy talks about what the screen shows rather than how
full it is.

`crop` takes `"head"` (keep the top, dissolve downward) or `"foot"` (keep the bottom,
dissolve upward). `keep` is how much of the screen survives and `fade` is where the
dissolve begins as a percentage of the kept strip — everything before it is fully
opaque, so a subject reaching further into the crop needs the dissolve to start later
or the subject itself goes translucent.

A cropped shot loses its device frame: the kept end keeps its real bezel and corner
radius, and the cut end has neither, because a dissolve and a drawn edge in the same
place fight each other. That is why a cropped shot sits slightly differently in the
set than its three framed siblings — deliberate, and the same trade Peach makes.

The captures themselves are untouched. This is a crop, not a composite.
