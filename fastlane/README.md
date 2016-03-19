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
### ios test
```
fastlane ios test
```
Run all the unit tests and generate a nice report

Report will open in default web browser after completing tests
### ios screenshots
```
fastlane ios screenshots
```
Build and create Screenshots

This action does the following:



- Invoke the Snapfile to create all the screenshots
### ios testflight
```
fastlane ios testflight
```
Submit a new Beta Build to Apple TestFlight

This action does the following:



- Increment the build number

- Build the app in 'Release' configuration

- Update all certs and mobile provisioning

- Upload to TestFlight (User needs to pull release trigger)

- Commit the build number change, tag and push to git

----

This README.md is auto-generated and will be re-generated every time to run [fastlane](https://fastlane.tools).  
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).  
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane).