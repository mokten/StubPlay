//
//
//  StubPlay.swift
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

import Foundation

public enum StubPlayConstants {
    public static let serverPort: in_port_t = 9081
}

/*
 
 Convenience class to use StubPlay
 
 */
public class StubPlay {
    
    public static let `default` = StubPlay()
    
    public let stubManager: StubManager
    public let serverPort: in_port_t
    public var stubServer: StubServer? = nil
    private var isEnabledServer = false {
        didSet {
            guard oldValue != isEnabledServer else { return }
             
            if isEnabledServer {
                do {
                    try stubServer?.start(port: StubPlayConstants.serverPort)
                } catch {
                    logger(error)
                }
            } else {
                stubServer?.stop()
            }
        }
    }
    
    private lazy var swizzle: Void = {
        swizzleProtocolClasses()
    }()
    
    public
    init(stubManager: StubManager = StubManager.shared, serverPort: in_port_t = StubPlayConstants.serverPort) {
        self.stubManager = stubManager
        self.serverPort = serverPort
    }
    
    public func start(with config: StubConfig = StubConfig()) throws {
        Logger.shared.isEnabled = config.isLogging
        
        stubManager.reset()
        StubURLProtocolStore.shared.updateSession(config: config.protocolURLSessionConfiguration)
        
        let filesManager = FilesManager(bundle: config.bundle, saveDirectoyURL: config.saveResponsesDirURL)
        if config.saveResponsesDirURL != nil {
            let saver = StubFileSaver(filesManager: filesManager)
            if config.clearSaveDir { saver.clear() }
            stubManager.stubSaver = saver
        }
        
        //
        try config.folders.forEach { folder in
            guard let stubCache = StubFolderCache(baseFolder: folder,
                                                  filesManager: filesManager,
                                                  forceSkipSave: config.skipSavingStubbedResponses,
                                                  validateResponseFile: config.validateResponseFile) else {
                throw StubPlayError.stubCacheLoad(nil, nil, folder)
            }
            stubManager.add(stubCache)
            do {
                try stubCache.load()
            } catch {
                throw StubPlayError.stubCacheLoad(error, stubCache, folder)
            }
        }
        
        self.isEnabledServer = config.isEnabledServer
        
        _ = swizzle
    }
    
    // Validates and removes invalid files
    public func validate(_ folder: String, with bundle: Bundle, removeInvalidFiles: Bool) throws -> [String] {
        let filesManager = FilesManager(bundle: bundle, saveDirectoyURL: nil)
        let baseURL = bundle.bundleURL.appendingPathComponent(folder)
        var missingFiles: [String?] = []
        
        try filesManager.urls(at: baseURL)?.forEach { url in
            let subFolder = folder + "/" + url.lastPathComponent
            guard let stubCache = StubFolderCache(baseFolder: subFolder, filesManager: filesManager) else {
                throw StubPlayError.stubCacheLoad(nil, nil, subFolder)
            }
            
            do {
                try stubCache.load()
                
                stubCache.requestStubs.values.forEach { stubs in
                    stubs.forEach { stub in
                        if try! !stubCache.hasValidResponseFile(for: stub) {
                            missingFiles.append(stubCache.responsePath(for: stub))
                        }
                    }
                }
                
            } catch {
                throw StubPlayError.stubCacheLoad(error, stubCache, folder)
            }
        }
        
        return missingFiles.compactMap { $0 }
    }
}

public enum StubPlayError: LocalizedError {
    case stubCacheLoad(Error?, StubFolderCache?, String?)
}
