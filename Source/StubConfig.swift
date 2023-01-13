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
     Global config file for StubManager.stubRules = StubRewriteRules
     */
    public var globalConfig: String?
    
    /*
     
     Folders that contain the stubbed files.
     
     Folders are loaded in order.
     
     */
    public var folders: [Folder]
    
    /*
     Folder where responses are saved.
     */
    public var saveResponsesDirURL: URL?
    
    /**
     if true then do not save responses that were originally stubbed
     */
    public var skipSavingStubbedResponses: Bool?
    
    /**
     if true then validates the response file on load of folder cache
     */
    public var validateResponseFile: Bool
    
    /*
     
     Clears the saved responses when re-running StubPlay
     
     no effect if saveResponses = false
     
     */
    public var clearSaveDir: Bool
    
    /*
     Update the URLProtocol session URLSessionConfiguration
     */
    public var protocolURLSessionConfiguration: URLSessionConfiguration?
    
    /*
     Bundle resource loader
     */
    public var bundle: Bundle
    
    /*
     
     Enables the server to play back HLS requests
     
     */
    public var isEnabledServer: Bool
    
    /*
     Shows logging in the console
     */
    public var isLogging: Bool
    
    /*
     Saves metrics
     */
    public var saveMetrics: Bool
    
    public init(globalConfig: String? = nil,
                folders: [Folder] = [],
                saveResponsesDirURL: URL? = FilesManager.defaultSaveDirURL,
                skipSavingStubbedResponses: Bool? = nil,
                validateResponseFile: Bool = true,
                clearSaveDir: Bool = true,
                bundle: Bundle = Bundle.main,
                isEnabledServer: Bool = true,
                protocolURLSessionConfiguration: URLSessionConfiguration? = nil,
                saveMetrics: Bool = false,
                isLogging: Bool = true) {
        self.globalConfig = globalConfig
        self.folders = folders
        self.clearSaveDir = clearSaveDir
        self.saveResponsesDirURL = saveResponsesDirURL
        self.skipSavingStubbedResponses = skipSavingStubbedResponses
        self.validateResponseFile = validateResponseFile
        self.bundle =  bundle
        self.isEnabledServer = isEnabledServer
        self.protocolURLSessionConfiguration = protocolURLSessionConfiguration
        self.saveMetrics = saveMetrics
        self.isLogging = isLogging
    }
}

extension StubConfig: CustomStringConvertible {
    public var description: String {
        "StubConfig(globalConfig=\(globalConfig?.description ?? "nil")\n"
        + "folders=\(folders)\n"
        + "saveResponsesDirURL=\(saveResponsesDirURL?.debugDescription ?? "nil")\n"
        + "skipSavingStubbedResponses=\(skipSavingStubbedResponses?.description ?? "nil")\n"
        + "validateResponseFile=\(validateResponseFile)\n"
        + "clearSaveDir=\(clearSaveDir)\n"
        + "bundle=\(bundle)\n"
        + "isEnabledServer=\(isEnabledServer)\n"
        + "protocolURLSessionConfiguration=\(protocolURLSessionConfiguration?.description ?? "nil")\n"
        + "saveMetrics=\(saveMetrics)\n"
        + "isLogging=\(isLogging))"
    }
}
