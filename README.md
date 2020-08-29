## Summary

Save and replay http requests in Swift

Stubs http responses and supports any http respons including text, html, json, images, videos and HLS.

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/StubPlay.svg)](https://img.shields.io/cocoapods/v/StubPlay.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/StubPlay.svg?style=flat)](https://github.com/mokten/StubPlay)

1. [Features](#features)
1. [Requirements](#requirements)
1. [Installation](#installation)
1. [Usage](#usage)
   1. [**Introduction**](./Usage.md#introduction)
1. [Concepts](#concepts)
1. [License](#license)

## Features
- [x] Saves full http request and responses
- [x] Unit tests are easy - no more having to write a bunch of boilerplate code for the network layer
- [x] Automated UI tests are easy too
- [x] Audit responses
  1.  Server side dev said they didn’t change anything but you can prove they did because you saved the responses
- [x] Api not ready? That’s ok you can create your own stubs and use them until the api is ready
- [x] Debug http requests - view requests being saved as responses are being processed
- [x] Replay customer experiences -> need to upload to your server yourself


## Requirements

- iOS 10.0+ / tvOS 11.0+
- Xcode 11.3+
- Swift 5.1+
- Cocoapods 1.7+
 
## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

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
try StubPlay.default.enableStub(for: ["Stub/default"])

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
        try? StubPlay.default.enableStub(for: Config(folders: ["Stub/default"], isEnabledServer: true, isLogging: true))
    }
    ...
}
```
## Concepts

1. Stubbed request / response has 2 files
  1. request+response/rewrite rule file -> json format
  1. response body file -> native format

The response body is in its own file so that it can be easily be used by viewers/editers ie. image, json, text, html, videos

## License

StubPlay is released under the MIT license. [See LICENSE](https://github.com/StubPlay/StubPlay/blob/master/LICENSE) for details.
