#!/bin/sh
# Capture the iPhone Duo's inner display into captures/iPhone Duo (inner)/.
#
# Not part of `fastlane screenshots`, and cannot be: XCUITest photographs and taps the
# cover display, and running it folds the simulator shut. So this launches the app
# straight into each screen with -ScreenshotScene (see ScreenshotMockData.Scene) and
# photographs display 3 from outside.
#
# Unfold the simulator by hand first, in the orientation you want -- nothing here can
# do that, and the script stops if the inner display is not the one that is lit.
set -eu

cd "$(dirname "$0")/.."
DEVICE="${1:-iPhone Duo}"
BUNDLE=com.cloudgatestudios.Bike-Buddy
OUT="AppStore/captures/iPhone Duo (inner)"
DERIVED="$(mktemp -d)"

xcodebuild -project BikeBuddy.xcodeproj -scheme BikeBuddy -configuration Release \
  -destination "platform=iOS Simulator,name=$DEVICE" -derivedDataPath "$DERIVED" \
  build > "$DERIVED/build.log" || { echo "build failed: $DERIVED/build.log"; exit 1; }
xcrun simctl install "$DEVICE" "$DERIVED/Build/Products/Release-iphonesimulator/BikeBuddy.app"
xcrun simctl status_bar "$DEVICE" override --time "9:41"

shoot() { # theme name wait [scene]
  xcrun simctl terminate "$DEVICE" "$BUNDLE" 2>/dev/null || true
  SIMCTL_CHILD_UI_TESTING_SCREENSHOTS=1 xcrun simctl launch "$DEVICE" "$BUNDLE" \
    UI_TESTING_SCREENSHOTS ${4:+-ScreenshotScene "$4"} > /dev/null
  sleep "$3"
  xcrun simctl io "$DEVICE" screenshot --display=3 "$OUT/$1/$2.png" > /dev/null 2>&1
}

for theme in light dark; do
  mkdir -p "$OUT/$theme"
  xcrun simctl ui "$DEVICE" appearance "$theme"
  sleep 2
  shoot "$theme" 01_StationsList 8
  shoot "$theme" 02_StationDetail 9 detail
  # Satellite tiles are fetched rather than restyled, so this one waits on the network.
  shoot "$theme" 03_Map 14 map
  shoot "$theme" 04_Networks 8 networks
done
xcrun simctl ui "$DEVICE" appearance light

# A folded Duo still answers for display 3, with a black frame, which compresses to
# around 100KB against a real capture's 2-3MB.
if [ "$(wc -c < "$OUT/light/01_StationsList.png")" -lt 200000 ]; then
  echo "The inner display is dark -- unfold the simulator and run this again."
  exit 1
fi
echo "Now run: python3 AppStore/compose.py --size duo-inner"
