#!/usr/bin/env python3
"""Compose App Store screenshots: a real capture, in a device frame, styled.

Two themes, from the same captures:

  street  light-mode app on pale concrete. The white screen and dark bezel separate
          hard from the ground, so the phone reads as an object sitting on something
          rather than a panel floating in the dark.
  dusk    dark-mode app on warm near-black, lit from above and behind.

Rendering is headless Chrome at an exact window size, so output is pixel-exact rather
than resampled -- no image library, nothing to install.
"""
import argparse, base64, pathlib, subprocess

HERE = pathlib.Path(__file__).parent
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# A family owns a stage, a device frame and a type scale; a size is one App Store
# Connect slot within a family. The design is authored once per family and scaled to
# the target slot by a single CSS transform on the whole stage, BEFORE rasterising, so
# radii, shadows, masks and type all scale together and nothing softens.
#
# iPad cannot share the phone's stage. Scale-by-width works for iPhone because every
# iPhone slot is within a hair of 0.46:1, so one canvas covers all of them. A 13" iPad
# is 0.75:1 -- scaling the phone stage to 2064 wide would put its foot well below the
# bottom edge, and the frame in the middle of it is phone-shaped anyway. What the two
# families share is what makes them look like one app: the ground, the lighting, the
# palette and the type pairing. What they do not share is any measurement.
FAMILIES = {
    "phone": dict(
        stage=(1320, 2868), captures="iPhone 17 Pro Max",
        padtop=136, padx=96,
        eyesize=27, eyegap=22, eyemb=44,
        hsize=126, subsize=38, submt=32, submax=1000,
        devw=940, devtop=690, bezel=15, devr=76, scrr=62,
        glowsize=2100, gshift=-190, lanesize=1580, lshift=320,
    ),
    "pad": dict(
        stage=(2064, 2752), captures="iPad Pro 13-inch (M5)",
        padtop=170, padx=150,
        eyesize=38, eyegap=30, eyemb=48,
        hsize=165, subsize=48, submt=40, submax=1560,
        devw=1300, devtop=800, bezel=22, devr=62, scrr=40,
        glowsize=2900, gshift=-260, lanesize=2300, lshift=430,
    ),
}

# Which slots exist depends on the listing, so check App Store Connect rather than
# assuming. Both of these are native: the capture device's screen IS the slot, so
# nothing inside a device frame is ever upscaled.
SIZES = {
    "6.9": ("phone", 1320, 2868),   # iPhone 17 Pro Max
    "13": ("pad", 2064, 2752),      # iPad Pro 13-inch
}

# Contrast measured against each theme's ground rather than eyeballed, because these
# are judged as thumbnails in search results before anyone opens one.
#
# The accent is the interesting case, and it is the same trap Peach hit with
# terracotta on clay: the app's own #3CA3DC manages just 1.74:1 on pale concrete, so
# the headline's second line would dissolve at thumbnail size. The light theme keeps
# the hue and drops the lightness until it clears 4.5:1.
THEMES = {
    "street": dict(
        suffix="light",
        ground="#CFCBC4", ground2="#B9B4AB",
        glow="rgba(240,238,234,.80)", glowfade="rgba(207,203,196,0)",
        ink="#23262B",           # 9.39:1 -- headline
        accent="#0F4C6B",        # 5.73:1 -- second line and eyebrow
        sub="#4E5560",           # 4.65:1 -- supporting line
        rule="rgba(15,76,107,.45)", rulefade="rgba(35,38,43,.10)",
        mark="rgba(252,252,250,.34)",             # lane markings on asphalt
        shadow="0 70px 120px rgba(40,44,52,.40), 0 22px 48px rgba(40,44,52,.30)",
        pool="rgba(46,50,58,.30)", vignette="rgba(74,78,86,.26)",
    ),
    "dusk": dict(
        suffix="dark",
        ground="#0A0B0D", ground2="#0A0B0D",
        glow="#16303D", glowfade="rgba(10,11,13,0)",
        ink="#EEF1F4",
        accent="#3CA3DC",
        sub="#7E868F",
        rule="rgba(60,163,220,.55)", rulefade="rgba(238,241,244,.07)",
        mark="rgba(238,241,244,.055)",
        shadow="0 60px 120px rgba(0,0,0,.78), 0 18px 46px rgba(0,0,0,.6)",
        pool="rgba(0,0,0,.55)", vignette="rgba(0,0,0,.55)",
    ),
}

CSS = """
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:%(W)spx;height:%(H)spx;overflow:hidden;background:%(ground)s}
.stage{position:absolute;top:0;left:0;width:%(SW)spx;height:%(SH)spx;
  transform:scale(%(k)s);transform-origin:top left;overflow:hidden;
  background:linear-gradient(170deg,%(ground)s 0%%,%(ground)s 58%%,%(ground2)s 100%%)}

/* One light source above and behind the device, so the ground reads as lit from a
   place rather than printed flat. */
.glow{position:absolute;left:50%%;top:%(glowtop)spx;width:%(glowsize)spx;height:%(glowsize)spx;
  margin-left:-%(glowhalf)spx;border-radius:50%%;
  background:radial-gradient(circle,%(glow)s 0%%,%(glowfade)s 70%%)}

/* Lane markings, faint, running under the device at a slant. One direction only:
   crossing two repeating gradients made a grid, which reads as graph paper rather
   than a road. Widely spaced and masked to a soft blob so it stays ground texture
   and never becomes a pattern the eye starts counting. */
.lane{position:absolute;left:50%%;top:%(lanetop)spx;width:%(lanesize)spx;height:%(lanesize)spx;
  margin-left:-%(lanehalf)spx;transform:rotate(-24deg);
  background:repeating-linear-gradient(0deg,
    %(mark)s 0 5px,transparent 5px 230px);
  opacity:.75;
  -webkit-mask-image:radial-gradient(circle,#000 0%%,transparent 62%%)}

/* Corners pulled down so the ground does not read as a flat swatch. */
.vignette{position:absolute;inset:0;
  background:radial-gradient(ellipse at 50%% 42%%,transparent 44%%,%(vignette)s 100%%)}

.wrap{position:absolute;top:%(padtop)spx;left:%(padx)spx;right:%(padx)spx}

/* Set like the header rule of a route sign: small, tracked out, with a rule running
   off to the right margin. */
.eyebrow{display:flex;align-items:center;gap:%(eyegap)spx;margin-bottom:%(eyemb)spx}
.eyebrow span{font:600 %(eyesize)spx/1 "SF Mono","SFMono-Regular",ui-monospace,Menlo,monospace;
  letter-spacing:.34em;color:%(accent)s;text-transform:uppercase;white-space:nowrap}
.eyebrow i{flex:1;height:2px;background:linear-gradient(90deg,%(rule)s,%(rulefade)s)}

/* DIN Condensed is the road-signage voice -- DIN 1451 is literally the German street
   sign face -- which is the register this subject already speaks in. */
h1{font:700 %(hsize)spx/0.96 "DIN Condensed","DIN Alternate",
  "Avenir Next Condensed",Impact,sans-serif;
  letter-spacing:.004em;color:%(ink)s;text-transform:uppercase}
/* The second line of every headline carries the accent. One screen doing it reads as
   that screen shouting; all of them doing it reads as a system. */
h1 em{font-style:normal;color:%(accent)s}

.sub{margin-top:%(submt)spx;max-width:%(submax)spx;
  font:400 %(subsize)spx/1.42 -apple-system,"SF Pro Text","Helvetica Neue",sans-serif;
  color:%(sub)s;letter-spacing:.002em}

/* Contact shadow where the device meets the ground. */
.pool{position:absolute;left:50%%;top:%(pooltop)spx;width:%(poolw)spx;height:150px;
  margin-left:-%(poolhalf)spx;border-radius:50%%;
  background:radial-gradient(ellipse,%(pool)s 0%%,transparent 72%%)}

.phone{position:absolute;left:50%%;top:%(devtop)spx;width:%(devw)spx;
  margin-left:-%(devhalf)spx;padding:%(bezel)spx;border-radius:%(devr)spx;
  background:linear-gradient(160deg,#4A4E55 0%%,#24272C 38%%,#16181C 100%%);
  box-shadow:%(shadow)s}
.screen{position:relative;border-radius:%(scrr)spx;overflow:hidden;
  height:%(croph)spx;background:#000}
.screen img{position:absolute;left:0;top:%(cropshift)spx;width:100%%;display:block}

/* A cropped shot ends in a dissolve rather than a cut, so the edge melts into the
   ground instead of drawing a line across the device.
     head -- keep the top of the screen; the foot dissolves downward
     foot -- keep the bottom of the screen; the head dissolves upward
   The kept end keeps its real bezel and corner radius; the cut end has neither,
   because a dissolve and a drawn edge in the same place fight each other.
   Everything before `fade` stays fully opaque, so a subject reaching further into the
   crop needs the dissolve to start later or the subject itself goes translucent. */
.crop{background:none;box-shadow:none}
.crop-head{padding:%(bezel)spx %(bezel)spx 0;border-radius:%(devr)spx %(devr)spx 0 0;
  -webkit-mask-image:linear-gradient(180deg,#000 %(fade)s%%,transparent 100%%)}
.crop-head .screen{border-radius:%(scrr)spx %(scrr)spx 0 0}
.crop-foot{padding:0 %(bezel)spx %(bezel)spx;border-radius:0 0 %(devr)spx %(devr)spx;
  -webkit-mask-image:linear-gradient(0deg,#000 %(fade)s%%,transparent 100%%)}
.crop-foot .screen{border-radius:0 0 %(scrr)spx %(scrr)spx}
"""

PAGE = """<!doctype html><html lang="en"><head><meta charset="utf-8"><style>%(css)s</style></head>
<body>
  <div class="stage">
  <div class="glow"></div>
  <div class="lane"></div>
  <div class="vignette"></div>
  <div class="wrap">
    <div class="eyebrow"><span>%(eyebrow)s</span><i></i></div>
    <h1>%(headline)s</h1>
    %(subhtml)s
  </div>
  %(poolhtml)s
  <div class="phone %(cropcls)s"><div class="screen"><img src="data:image/png;base64,%(img)s"></div></div>
  </div>
</body></html>"""

# Ordered as they appear on the listing. The stations list leads because it is the
# question the app answers, and because the first screenshot is the one that shows up
# in search results.
SPECS = {
 "phone": [
    ("01-stations", "Nearby", "Bikes near you,<br><em>right now.</em>",
     "The closest stations, sorted by how far you actually have to walk &mdash; with how "
     "many bikes and docks each one has this minute."),
    ("02-map", "Map", "Street map,<br><em>or satellite.</em>",
     "Switch the map when the corner matters &mdash; which side of the street the rack "
     "is on, which park path actually gets you there."),
    ("03-detail", "Station", "Bikes, docks,<br><em>and the walk.</em>",
     "Tap any station for its counts and a walking route straight into Maps."),
    ("04-networks", "Coverage", "800+ networks.<br><em>One app.</em>",
     "Bike share in more than 50 countries, from Citi Bike to the scheme in the town "
     "you are visiting next week. Search by city or by name."),
 ],
 # The iPad order mirrors the phone's, for the same reasons.
 "pad": [
    ("01-stations", "Nearby", "Bikes near you,<br><em>right now.</em>",
     "The closest stations, sorted by how far you actually have to walk &mdash; with how "
     "many bikes and docks each one has this minute."),
    ("02-map", "Map", "Street map,<br><em>or satellite.</em>",
     "Switch the map when the corner matters &mdash; which side of the street the rack "
     "is on, which park path actually gets you there."),
    # This used to be cropped: a station's detail was its own screen, it did not fill
    # 1376pt of portrait iPad, and the foot of it was white. There is no such screen
    # any more -- choosing a station keeps the map and puts the counts and actions on a
    # card over it -- so the capture is full bleed and the payload is the card along
    # the bottom. Cropping the head off that now would take the card with it.
    ("03-detail", "Station", "Bikes, docks,<br><em>and the walk.</em>",
     "Tap any station for its counts and a walking route straight into Maps."),
    ("04-networks", "Coverage", "800+ networks.<br><em>One app.</em>",
     "Bike share in more than 50 countries, from Citi Bike to the scheme in the town "
     "you are visiting next week. Search by city or by name."),
 ],
}

# fastlane names captures <device>/<lang>-<NN_Name>.png; compose refers to shots by the
# spec name, so map one to the other in one place.
CAPTURE_NAMES = {
    "01-stations": "01_StationsList",
    "02-map": "03_Map",
    "03-detail": "02_StationDetail",
    "04-networks": "04_Networks",
}


def build(theme, size, name, eyebrow, headline, sub, *,
          crop=None, keep=0.60, fade=78, **over):
    """crop: None, "head" (keep the top of the screen) or "foot" (keep the bottom).

    over: any FAMILIES key, overridden for this one shot.
    """
    t = THEMES[theme]
    family, W, H = SIZES[size]
    f = {**FAMILIES[family], **over}
    stage_w, stage_h = f["stage"]

    shot = HERE / "captures" / f["captures"] / t["suffix"] / f"{CAPTURE_NAMES[name]}.png"
    if not shot.exists():
        return None

    devw, devtop = f["devw"], f["devtop"]
    # The capture fills the screen, not the whole device: the bezel is padding around
    # it. Measuring from devw instead left the screen taller than the image and showed
    # a band of the #000 backing below the capture.
    screenw = devw - 2 * f["bezel"]
    full = round(screenw * stage_h / stage_w)     # the capture at this width
    croph = round(full * keep) if crop else full
    cropshift = -(full - croph) if crop == "foot" else 0
    # A visible bottom bezel earns a contact shadow; an edge that dissolves does not --
    # the fade is already doing that job.
    pooltop = devtop + croph + (16 if crop else -26)
    poolw = round(devw * 1.02)

    css = CSS % dict(W=W, H=H, SW=stage_w, SH=stage_h, k=round(W / stage_w, 6),
                     devw=devw, devtop=devtop, devhalf=devw // 2,
                     glowtop=devtop + f["gshift"], glowhalf=f["glowsize"] // 2,
                     lanetop=devtop + f["lshift"], lanehalf=f["lanesize"] // 2,
                     croph=croph, cropshift=cropshift, fade=fade,
                     pooltop=pooltop, poolw=poolw, poolhalf=poolw // 2,
                     **{k: f[k] for k in ("padtop", "padx", "eyesize", "eyegap",
                                          "eyemb", "hsize", "subsize", "submt",
                                          "submax", "bezel", "devr", "scrr",
                                          "glowsize", "lanesize")},
                     **t)

    cropcls = f"crop crop-{crop}" if crop else ""
    html = PAGE % dict(css=css, eyebrow=eyebrow, headline=headline,
                       img=base64.b64encode(shot.read_bytes()).decode(),
                       cropcls=cropcls,
                       poolhtml="" if crop == "head" else '<div class="pool"></div>',
                       subhtml=f'<p class="sub">{sub}</p>' if sub else "")

    (HERE / "build").mkdir(exist_ok=True)
    dest = HERE / "screenshots" / size / theme
    dest.mkdir(parents=True, exist_ok=True)
    src = HERE / "build" / f"{size}-{theme}-{name}.html"
    src.write_text(html)
    out = dest / f"{name}.png"
    subprocess.run([CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
                    "--force-device-scale-factor=1", f"--screenshot={out}",
                    f"--window-size={W},{H}", str(src)], check=True, capture_output=True)
    return out


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--theme", choices=[*THEMES, "all"], default="all")
    ap.add_argument("--size", choices=[*SIZES, "all"], default="all")
    opts = ap.parse_args()
    for size in (SIZES if opts.size == "all" else [opts.size]):
        for theme in (THEMES if opts.theme == "all" else [opts.theme]):
            for spec in SPECS[SIZES[size][0]]:
                *rest, kw = spec if isinstance(spec[-1], dict) else (*spec, {})
                out = build(theme, size, *rest, **kw)
                print("wrote", out) if out else print(f"skip  {size}/{theme}/{spec[0]}")
