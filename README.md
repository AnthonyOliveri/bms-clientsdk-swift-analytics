IBM Bluemix Mobile Services - Client SDK Swift Analytics
===================================================

[![Build Status](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-analytics.svg?branch=master)](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-analytics)
[![Build Status](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-analytics.svg?branch=development)](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-analytics)

This is the analytics and logger component of the Swift SDK for [IBM Bluemix Mobile Services](http://www.ibm.com/cloud-computing/bluemix/mobile/).


## Requirements
* iOS 8.0+ / watchOS 2.0+
* Xcode 7


## Installation
The Bluemix Mobile Services Swift SDKs are available via [Cocoapods](http://cocoapods.org/) and [Carthage](https://github.com/Carthage/Carthage).

### Cocoapods
To install BMSAnalytics using Cocoapods, add it to your Podfile:

```ruby
use_frameworks!

target 'MyApp' do
    pod 'BMSAnalytics'
end
```

Then run the `pod install` command.

#### Swift 2.3

For apps built with Swift 2.3, you may receive a prompt saying "Convert to Current Swift Syntax?" when opening your project in Xcode 8 (following the installation of BMSAnalytics). Choose the *Convert* option, and select `BMSCore.framework`, `BMSAnalyticsAPI.framework`, and `BMSAnalytics.framework`.
**Note:** This should only be done once. If the prompt appears again in the future after you have already converted, always choose the *Later* option.

#### Swift 3.0

For apps built with Swift 3.0, you may receive a prompt saying "Convert to Current Swift Syntax?" when opening your project in Xcode 8 (following the installation of BMSAnalytics). Always choose the *Later* option. 


### Carthage
To install BMSAnalytics using Carthage, add it to your Cartfile: 

```ogdl
github "ibm-bluemix-mobile-services/bms-clientsdk-swift-analytics"
```

Then run the `carthage update` command. Once the build is finished, drag the `BMSAnalytics.framework`, `BMSCore.framework`, and `BMSAnalyticsAPI.framework` files into your Xcode project. 

To complete the integration, follow the instructions [here](https://github.com/Carthage/Carthage#getting-started).

#### Swift 2.3

For apps built with Swift 2.3, change the [Command Line Tools](https://developer.apple.com/library/mac/recipes/xcode_help-locations_preferences/SpecifyingCommandLineTools/SpecifyingCommandLineTools.html) setting in Xcode preferences to `Xcode 8.0`, then run the bash command `TOOLCHAINS=com.apple.dt.toolchain.Swift_2_3 carthage update`. 

#### Swift 3.0

For apps built with Swift 3.0, change the [Command Line Tools](https://developer.apple.com/library/mac/recipes/xcode_help-locations_preferences/SpecifyingCommandLineTools/SpecifyingCommandLineTools.html) setting in Xcode preferences to `Xcode 8.0`, then run the `carthage update` command.


=======================
Copyright 2015 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
