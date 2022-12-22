//
//  MainViewController.swift
//  Example-iOS
//
//  Created by Yoo-Jin Lee on 6/6/19.
//  Copyright © 2019 Mokten Pty Ltd. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    let videoByteRangeURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!
    let videoURL = URL(string: "https://devstreaming-cdn.apple.com/master.m3u8")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [
            SkipStubPlayViewController(),
            MultipleViewController(),
            VideoPlayerViewController("Video Byte Range", url: videoByteRangeURL),
            VideoPlayerViewController("Video", url: videoURL),
            ImageViewController(),
            RewriteRuleViewController(),
            UIViewController.swiftUIDemoView
        ].map { UINavigationController(rootViewController: $0) }
        
    }
}
