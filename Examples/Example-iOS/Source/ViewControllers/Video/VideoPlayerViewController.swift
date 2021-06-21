//
//
//  VideoPlayerViewController.swift
//
//  Copyright © 2019 Mokten Pty Ltd. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import AVKit
import AVFoundation
import StubPlay

class VideoPlayerViewController: NiblessViewController {
    
    private let url: URL
    private lazy var assetResourceLoader = StubPlay.default.resourceLoader()
    private var asset: AVURLAsset?

    private let playerController = AVPlayerViewController()
    private var playerItem: AVPlayerItem?
    private var player: AVPlayer?

    // KVO
    var statusObservation: NSKeyValueObservation?
    
    init(_ title: String, url: URL) {
        self.url = url
        super.init()
        self.title = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let asset = assetResourceLoader.avAsset(with: url)
        self.asset = asset
        asset.loadValuesAsynchronously(forKeys: ["playable", "hasProtectedContent"]) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                // We can't play this asset.
                guard asset.isPlayable else {
                    print("Can't use this AVAsset playable=\(!asset.isPlayable) or has protected content=\(asset.hasProtectedContent)")
                    return
                }

                self.playerItem = AVPlayerItem(asset: asset)
                let player = AVPlayer(playerItem: self.playerItem)
                self.player = player

                self.statusObservation = player.currentItem?.observe(\.status) { currentItem, _ in
                    let newStatus = currentItem.status
                    if newStatus == .failed, let error = currentItem.error {
                        print(error.localizedDescription)
                    }
                }

                self.playerController.player = player

                self.addChild(self.playerController)
                self.playerController.view.frame = self.view.frame
                self.view.addSubview(self.playerController.view)

                self.playerController.didMove(toParent: self)
                player.play()
            }

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player?.pause()
        super.viewWillDisappear(animated)
    }

}
