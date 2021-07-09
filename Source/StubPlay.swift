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
import AVFoundation

public enum StubPlayConstants {
    public static let serverPort: in_port_t = 9081
}

/*
 
 Convenience class to use StubPlay
 
 */
public class StubPlay {
    
    public static let `default` = StubPlay()
    
    public var config: StubConfig?
    private weak var session: URLSession?
    public let stubManager: StubManager
    public let serverPort: in_port_t
    public var stubServer: StubServer? = nil
    private var isEnabledServer = false {
        didSet {
            guard oldValue != isEnabledServer else { return }
            
            if isEnabledServer {
                do {
                    let stubServer = StubServer(stubManager: stubManager)
                    self.stubServer = stubServer
                    let ip = try stubServer.start(port: serverPort)
                    logger(level: .warn, ip)
                    
                    avPlayerResourceLoader = AssetResourceLoader(session: session!, stubManager: stubManager, port: Int(self.serverPort))
                    
                } catch {
                    logger(error: error)
                }
            } else {
                stubServer?.stop()
                stubServer = nil
            }
        }
    }
    
    private var avPlayerResourceLoader: AssetResourceLoader?
    
    private lazy var swizzle: Void = {
        swizzleProtocolClasses()
    }()
    
    public
    init(stubManager: StubManager = StubManager.shared, serverPort: in_port_t = StubPlayConstants.serverPort) {
        self.stubManager = stubManager
        self.serverPort = serverPort
    }
    
    public func start(with config: StubConfig = StubConfig()) throws {
        self.config = config
        Logger.shared.isEnabled = config.isLogging
        
        stubManager.reset()
        session = StubURLProtocolStore.shared.updateSession(config: config.protocolURLSessionConfiguration)
        
        StubResourceLoaderStore.shared.update(config: config.protocolURLSessionConfiguration, stubManager: stubManager, port: Int(serverPort))
        
        let filesManager = FilesManager(bundle: config.bundle, saveDirectoyURL: config.saveResponsesDirURL)
        
        if let globalConfig = config.globalConfig, let configURL = filesManager.bundleUrl(for: globalConfig) {
            do {
                stubManager.stubRules = try filesManager.get(StubRewriteRules.self, from: configURL)
            } catch {
                logger(error)
            }
        }
        
        if config.saveResponsesDirURL != nil {
            let saver = StubFileSaver(filesManager: filesManager)
            if config.clearSaveDir { saver.clear() }
            stubManager.stubSaver = saver
        }

        try config.folders.forEach { folder in
            guard let stubCache = StubFolderCache(baseFolder: folder,
                                                  filesManager: filesManager,
                                                  forceSkipSave: config.skipSavingStubbedResponses,
                                                  validateResponseFile: config.validateResponseFile) else {
                throw StubPlayError.stubCacheLoad(nil, nil, folder)
            }
            stubManager.add(stubCache)
            stubCache.load()
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
            stubCache.load()
            
            stubCache.requestStubs.values.forEach { stubs in
                stubs.forEach { stub in
                    if try! !stubCache.hasValidResponseFile(for: stub) {
                        missingFiles.append(stubCache.responsePath(for: stub))
                    }
                }
            }
        }
        
        return missingFiles.compactMap { $0 }
    }
}

extension StubPlay {
    public func avAsset(url: URL, options: [String: Any]? = nil) -> AVURLAsset {        
        if let avPlayerResourceLoader = avPlayerResourceLoader {
            return avPlayerResourceLoader.avAsset(with: url, options: options)
        } else {
            return AVURLAsset(url: url, options: options)
        }
    }
    
    public func resourceLoader() -> AssetResourceLoader {
        guard let avPlayerResourceLoader = avPlayerResourceLoader else {
            fatalError("Please enable the server")
        }
        return avPlayerResourceLoader
    }
}

public enum StubPlayError: LocalizedError {
    case stubCacheLoad(Error?, StubFolderCache?, String?)
}
