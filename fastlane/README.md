fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios setup
```
fastlane ios setup
```
Setup the workspace for development

Should be ran by all developers before starting any development
### ios carthageUpdate
```
fastlane ios carthageUpdate
```
Update all dependencies managed by Carthage
### ios testApp
```
fastlane ios testApp
```
Run all the unit tests and generate a nice report

Report will open in default web browser after completing tests
### ios createScreenshots
```
fastlane ios createScreenshots
```
Build and create Screenshots

This action does the following:



- Invoke the Snapfile to create all the screenshots
### ios updateVersionNumber
```
fastlane ios updateVersionNumber
```

### ios sendBuildToAppStore
```
fastlane ios sendBuildToAppStore
```
Submit a new build to the App Store

This action does the following:



- Increment the build number

- Build the app in 'Release' configuration

- Update all certs and mobile provisioning

- Upload to TestFlight (User needs to pull release trigger)

- Commit the build number change, tag and push to git

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).
