//
//  Config.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/3/20.
//  Copyright © 2020 Mokten Pty Ltd. All rights reserved.
//

import Foundation

public struct StubConfig {
    /*
     
     Folders that contain the stubbed files.
     
     Folders are loaded in order.
     
     */
    public var folders: [Folder]
    
    /*
     Save responses in the order they were processed.
     */
    public var saveResponses: Bool
    
    /*
     
     Clears the saved responses when re-running StubPlay
     
     no effect if saveResponses = false
     
     */
    public var clearSaveDir: Bool
    
    /*
     Bundle resource loader
     */
    public var bundle: Bundle
    
    /*
     
     Enables the server to play back HLS requests
     
     */
    public var isEnabledServer: Bool
    
    /*
     Shows loggin in the console
     */
    public var isLogging: Bool
    
    public init(folders: [Folder] = [],
                saveResponses: Bool = false,
                clearSaveDir: Bool = true,
                bundle: Bundle = Bundle.main,
                isEnabledServer: Bool = false,
                isLogging: Bool = false) {
        self.folders = folders
        self.saveResponses = saveResponses
        self.clearSaveDir = clearSaveDir
        self.bundle =  bundle
        self.isEnabledServer = isEnabledServer
        self.isLogging = isLogging
    }
}
