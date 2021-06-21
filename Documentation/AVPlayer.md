- [AVPlayer](#avplayer-stubplay)

# Using StubPlay with AVPlayer

## Introduction

StubPlay lets you stub resources in AVPlayer

## Saving Requests
No extra configuration is needed if you want to save all requests and responses from AVPlayer.

However, if you want to replay your saved stubs then you must do the following:
  1. Start the StubServer
  1. Set AVURLAsset's resource loader delegate

```swift
let config = StubConfig(folders: ["Stub/default"],
                        isEnabledServer: true,
                        isLogging: true)
try StubPlay.default.start(with: config)
```


```swift
class VideoPlayerViewController {
     
    // You must keep a strong reference to the StubPlay resourceLoader
    private lazy var assetResourceLoader = StubPlay.default.resourceLoader()
        
    private var playerItem: AVPlayerItem?
    private var player: AVPlayer?
        
    func startPlayer() {    
        // Use the convenience helper to create an AVURLAsset
        let asset = assetResourceLoader.avAsset(with: url, options: nil)
            
        asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
                self.playerItem = AVPlayerItem(asset: asset)
                let player = AVPlayer(playerItem: self.playerItem)
                self.player = player
        }
    }
    
``` 

[**Video example**](../Examples/Example-iOS/Source/ViewControllers/Video/VideoPlayerViewController.swift)
