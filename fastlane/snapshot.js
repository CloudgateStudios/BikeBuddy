#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.delay(3)
target.frontMostApp().tabBar().buttons()["Stations List"].tap();
captureLocalizedScreenshot("0-StationsList")

target.delay(3)
target.frontMostApp().tabBar().buttons()["Map"].tap();
target.frontMostApp().mainWindow().elements()[1].elements()["Lake Shore Dr & North Blvd, Bikes: 5 Open Docks: 9"].tap();
captureLocalizedScreenshot("1-Map")

target.delay(3)
target.frontMostApp().tabBar().buttons()["Settings"].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()["City"].tap();
captureLocalizedScreenshot("2-Cities")

/*target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
target.frontMostApp().tabBar().buttons()["Stations List"].tap();
target.frontMostApp().tabBar().buttons()["Map"].tap();
target.frontMostApp().mainWindow().elements()[1].elements()["Lake Shore Dr & North Blvd, Bikes: 5 Open Docks: 9"].tap();
target.frontMostApp().tabBar().buttons()["Settings"].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()["City"].tap();*/
