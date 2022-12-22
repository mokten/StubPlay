//
//  StubManager.swift
//  Example-iOS
//
//  Created by Yoo-Jin Lee on 22/12/2022.
//  Copyright © 2022 Mokten Pty Ltd. All rights reserved.
//

import Foundation
import StubPlay

class StubManager {
    
    static let shared = StubManager()
    
    var isStubbing: Bool {
        StubPlay.default.isStubbing
    }
    
    func start() {
        do {
            let config = StubConfig(
                globalConfig: "Video/.config",
                folders: ["Text", "Image", "Alamofire",
                          "Video/Segment", "Video/ByteRange",
                          "Multiple", "RewriteRule"],
                saveResponsesDirURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("stubplay"),
                skipSavingStubbedResponses: false,
                validateResponseFile: false,
                clearSaveDir: true,
                bundle: Bundle.main,
                isEnabledServer: true,
                protocolURLSessionConfiguration: nil,
                isLogging: true)
            try StubPlay.default.start(with: config)
        } catch {
            print(error)
        }
    }
    
    func stop() {
        StubPlay.default.stop()
    }
}
