//
//  Config.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/3/20.
//  Copyright © 2020 Mokten Pty Ltd. All rights reserved.
//

import Foundation

public struct Config {
    public var folders: [Folder]
    public var saveResponses: Bool
    public var clearSaveDir: Bool
    public var bundle: Bundle
    public var isEnabledServer: Bool
    
    public init(folders: [Folder] = [],
                saveResponses: Bool = true,
                clearSaveDir: Bool = true,
                bundle: Bundle = Bundle.main,
                isEnabledServer: Bool = false) {
        self.folders = folders
        self.saveResponses = saveResponses
        self.clearSaveDir = clearSaveDir
        self.bundle =  bundle
        self.isEnabledServer = isEnabledServer
    }
}
