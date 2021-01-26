## Summary

Save and replay http requests in Swift

Stubs http responses and supports any http response including text, html, json, images, videos and HLS.

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/StubPlay.svg)](https://img.shields.io/cocoapods/v/StubPlay.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/StubPlay.svg?style=flat)](https://github.com/mokten/StubPlay)

1. [Features](#features)
1. [Requirements](#requirements)
1. [Compatible](#compatible)
1. [Installation](#installation)
1. [Usage](#usage)
   1. [**Usage**](./Documentation/Usage.md)
   1. [**Unit Test**](./Documentation/UnitTest.md)
1. [Concepts](#concepts)
1. [License](#license)

## Features
- [x] Saves full http request and responses
- [x] Unit tests are easy - no more having to write a bunch of boilerplate code for the network layer
- [x] Automated UI tests are easy too
- [x] Audit responses
  1.  Server side dev said they didn’t change anything but you can prove they did because you saved the responses
- [x] Api not ready? That’s ok you can create your own stubs and use them until the api is ready
- [x] Debug http requests - view requests being saved as responses are being consumed by your App
- [x] Replay customer experiences -> need to upload to your server yourself


## Requirements

- iOS 10.0+ / tvOS 11.0+
- Xcode 11.3+
- Swift 5.1+
 
## Installation

### Swift Package Manager (SPM)

```swift
dependencies: [
    .package(name: "StubPlay", url: "https://github.com/mokten/StubPlay.git", .upToNextMajor(from: "0.1.11"))
]
```

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

- Cocoapods 1.7+


```bash
$ gem install cocoapods
```

> CocoaPods 1.7+ is required to build StubPlay 

To integrate StubPlay into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'StubPlay'
end
```

Then, run the following command:

```bash
$ pod install
```  

### Carthage

- Carthage 0.33+

Cartfile
```ogdl
github "mokten/StubPlay"
```


## Usage

We recommend enabling stubs as soon as possible - in your main.swift file or App delegate init()

By default: requests/response are saved in the `caches/com.mokten.stubplay` directory.
Every time the app is run this directory will be cleared out.

Add a reference folder to your app. ie. "Stub/default", this is where your stubs will be read from

```swift
import StubPlay

// This will save all requests and responses to the app cache directory
// Start the app and navigate around
// Once you have completed your scenario then copy the files in the cache directory to your reading stub directory "Stub/default"
try? StubPlay.default.enableStub(for: StubConfig(folders: ["Stub/default"], isEnabledServer: true, isLogging: true))

_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, NSStringFromClass(Application.self), NSStringFromClass(AppDelegate.self))
```

or

```swift
import UIKit
import StubPlay

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    override init() {
        super.init()
        try? StubPlay.default.enableStub(for: StubConfig(folders: ["Stub/default"], isEnabledServer: true, isLogging: true))
    }
    ...
}
```
 
Optionally, all requests are saved to the Caches directory (this can be turned off with configuration):

ie:
~/Library/Developer/CoreSimulator/Devices/C62F6E5A-6459-45B6-B20B-B7C8E07AA529/data/Containers/Data/Application/1C1E61F8-B7B9-45FA-AA7E-7928E8952989/Library/Caches/com.mokten.stubplay

## Concepts

1. Stubbed request / response has 2 files
  1. request+response/rewrite rule file -> json format
  1. response body file -> native format

The response body is in its own file so that it can be easily be used by viewers/editers ie. image, json, text, html, videos

## License

StubPlay is released under the MIT license. [See LICENSE](https://github.com/StubPlay/StubPlay/blob/master/LICENSE) for details.
