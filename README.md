 ## Summary
 Save and replay http requests
 Handles various http responses and includes text, html, json,, and images

 ## Requirements

- iOS 11.0+ / tvOS 11.0+
- Xcode 10.2+
- Swift 5+
 
## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.5+ is required to build StubPlay 

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

We recommend enabling stubs as soon as possible - in you main file or App delegate.

By default: requests/response are saved in the "com.mokten.stubplay" directory
Add a reference folder to your app. ie. "Stub/default", this is where your stubs will be read from

```java
import StubPlay

// This will save all requests and responses to the app cache directory
// Start the app and navigate around
// Once you have completed your scenario then copy the files in the cache directory to your reading stub directory "Stub/default"
try StubPlay.default.enableStub(for: ["Stub/default"])

_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, NSStringFromClass(Application.self), NSStringFromClass(AppDelegate.self))
```



## License

StubPlay is released under the MIT license. [See LICENSE](https://github.com/StubPlay/StubPlay/blob/master/LICENSE) for details.
