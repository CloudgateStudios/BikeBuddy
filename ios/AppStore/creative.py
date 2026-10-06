#!/usr/bin/env python3
"""Compose the App Store creative assets: the product page header and the search
results image.

These are not screenshots. They sit in their own placements, at their own sizes, and
App Store Connect crops them differently per device and orientation -- so unlike
compose.py, where the stage IS the slot and everything is placed to the pixel, the
rule here is that anything that matters stays in the middle of the frame. `safe` is
the fraction of the width the headline and the device are held inside; the ground,
glow and lane markings run to the edges because losing them costs nothing.

Same themes, palette, type and captures as compose.py, so the header, the search
result and the screenshots under them read as one listing.
"""
import argparse, base64, subprocess

from compose import CHROME, HERE, THEMES

# Sizes from App Store Connect's creative asset specifications. Both are the largest
# the placement takes. There is also a 16:9 "universal" size that serves both
# placements from one image; it is not used because the two placements want different
# things -- the header a single idea in a wide strip, search the app itself.
ASSETS = {
    # 21:9. Too short to stand a phone up in, so the phone runs off the top and the
    # bottom and the strip shows the middle of the screen: the pins, the panel header
    # and the first rows. `devtop` is negative on purpose.
    "header": dict(
        size=(3840, 1646), safe=0.66,
        hsize=262, subsize=0, gap=150,
        devw=1000, devtop=-330, bezel=16, devr=82, scrr=66,
        glowsize=3000, lanesize=2600,
    ),
    # 3:2. Tall enough for the whole phone, and search is where someone is deciding
    # what the app is, so this one carries the supporting line as well.
    "search": dict(
        size=(3840, 2560), safe=0.70,
        hsize=284, subsize=76, gap=170,
        devw=1040, devtop=150, bezel=16, devr=84, scrr=68,
        glowsize=3600, lanesize=3000,
    ),
}

HEADLINE = "Bikes near you,<br><em>right now.</em>"
SUB = "Live bikes and docks at the stations closest to you, across 800+ networks."
CAPTURE = ("iPhone 17 Pro Max", "01_StationsList")

CSS = """
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:%(W)spx;height:%(H)spx;overflow:hidden;background:%(ground)s}
.stage{position:absolute;inset:0;overflow:hidden;
  background:linear-gradient(170deg,%(ground)s 0%%,%(ground)s 58%%,%(ground2)s 100%%)}
.glow{position:absolute;left:%(devcx)spx;top:50%%;width:%(glowsize)spx;height:%(glowsize)spx;
  margin:-%(glowhalf)spx 0 0 -%(glowhalf)spx;border-radius:50%%;
  background:radial-gradient(circle,%(glow)s 0%%,%(glowfade)s 70%%)}
.lane{position:absolute;left:%(devcx)spx;top:50%%;width:%(lanesize)spx;height:%(lanesize)spx;
  margin:-%(lanehalf)spx 0 0 -%(lanehalf)spx;transform:rotate(-24deg);
  background:repeating-linear-gradient(0deg,%(mark)s 0 8px,transparent 8px 360px);
  opacity:.75;-webkit-mask-image:radial-gradient(circle,#000 0%%,transparent 62%%)}
.vignette{position:absolute;inset:0;
  background:radial-gradient(ellipse at 50%% 46%%,transparent 44%%,%(vignette)s 100%%)}

/* The copy is centred on the frame's height and ends `gap` short of the device, so
   the pair sits in the middle of the frame however the edges are cropped. */
.copy{position:absolute;left:%(safex)spx;width:%(copyw)spx;top:0;bottom:0;
  display:flex;flex-direction:column;justify-content:center}
h1{font:700 %(hsize)spx/0.96 "DIN Condensed","DIN Alternate",
  "Avenir Next Condensed",Impact,sans-serif;
  letter-spacing:.004em;color:%(ink)s;text-transform:uppercase;white-space:nowrap}
h1 em{font-style:normal;color:%(accent)s}
.sub{margin-top:%(submt)spx;
  font:400 %(subsize)spx/1.36 -apple-system,"SF Pro Text","Helvetica Neue",sans-serif;
  color:%(sub)s}

.phone{position:absolute;left:%(devx)spx;top:%(devtop)spx;width:%(devw)spx;
  padding:%(bezel)spx;border-radius:%(devr)spx;
  background:linear-gradient(160deg,#4A4E55 0%%,#24272C 38%%,#16181C 100%%);
  box-shadow:%(shadow)s}
.screen{border-radius:%(scrr)spx;overflow:hidden;background:#000}
.screen img{width:100%%;display:block}
"""

PAGE = """<!doctype html><html lang="en"><head><meta charset="utf-8"><style>%(css)s</style></head>
<body><div class="stage">
  <div class="glow"></div><div class="lane"></div><div class="vignette"></div>
  <div class="copy"><h1>%(headline)s</h1>%(subhtml)s</div>
  <div class="phone"><div class="screen"><img src="data:image/png;base64,%(img)s"></div></div>
</div></body></html>"""


def build(theme, name):
    t, a = THEMES[theme], ASSETS[name]
    W, H = a["size"]
    shot = HERE / "captures" / CAPTURE[0] / t["suffix"] / f"{CAPTURE[1]}.png"
    if not shot.exists():
        return None

    safex = round(W * (1 - a["safe"]) / 2)
    devx = W - safex - a["devw"]
    css = CSS % dict(W=W, H=H, safex=safex, devx=devx, devcx=devx + a["devw"] // 2,
                     copyw=devx - a["gap"] - safex,
                     glowhalf=a["glowsize"] // 2, lanehalf=a["lanesize"] // 2,
                     submt=round(a["subsize"] * 0.7),
                     **{k: a[k] for k in ("hsize", "subsize", "devw", "devtop", "bezel",
                                          "devr", "scrr", "glowsize", "lanesize")},
                     **t)
    html = PAGE % dict(css=css, headline=HEADLINE,
                       subhtml=f'<p class="sub">{SUB}</p>' if a["subsize"] else "",
                       img=base64.b64encode(shot.read_bytes()).decode())

    (HERE / "build").mkdir(exist_ok=True)
    dest = HERE / "creative" / theme
    dest.mkdir(parents=True, exist_ok=True)
    src = HERE / "build" / f"creative-{theme}-{name}.html"
    src.write_text(html)
    out = dest / f"{name}.png"
    subprocess.run([CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
                    "--force-device-scale-factor=1", f"--screenshot={out}",
                    f"--window-size={W},{H}", str(src)], check=True, capture_output=True)
    return out


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--theme", choices=[*THEMES, "all"], default="all")
    ap.add_argument("--asset", choices=[*ASSETS, "all"], default="all")
    opts = ap.parse_args()
    for theme in (THEMES if opts.theme == "all" else [opts.theme]):
        for name in (ASSETS if opts.asset == "all" else [opts.asset]):
            out = build(theme, name)
            print("wrote", out) if out else print(f"skip  {theme}/{name}")
