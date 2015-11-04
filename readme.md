# Bike Buddy
![Bike Buddy Icon]
(https://raw.githubusercontent.com/tomarra/Bike-Buddy/master/Bike%20Buddy/Images.xcassets/AppIcon.appiconset/AppIcon%403x.png)

## Overview
A simple iOS app to get the nearest bike sharing stations to you. Works off of the fact that the company Bixi has a similar API for a lot of their bike sharing systems.

## Setup
1. Install xctool
  * `sudo brew install xctool`
2. Install [Fastlane](https://fastlane.tools)
  * `sudo gem install fastlane`
3. Setup folders so Fastlane can update itself
  * Add the following to your .bash_profile file so it gets picked up at every Terminal launch
    * `export GEM_HOME=~/.gems`
    * `export PATH=$PATH:~/.gems/bin`
  * `mkdir $GEM_HOME`
4. Install [Carthage](https://github.com/Carthage/Carthage)
  * `sudo brew install carthage`
5. Get the workspace ready
 * `fastlane ios setup`
6. Open up the project file in Xcode 7.1

## Third Party Use
* [Alamofire](https://github.com/Alamofire/Alamofire)
* [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper)
* [AlamofireObjectMapper](https://github.com/tristanhimmelman/AlamofireObjectMapper)
* [SVProgressHUD](https://github.com/TransitApp/SVProgressHUD)
