//
//  StubPlay+Extension.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/3/20.
//  Copyright © 2020 Mokten Pty Ltd. All rights reserved.
//

import Foundation

public extension StubPlay {
    
    // Convenience helper
    func enableStub(for config: Config = Config()) throws {
        stubManager.reset()
        let filesManager = FilesManager(bundle: config.bundle)
        let saver = StubFileSaver(filesManager: filesManager)
        if config.clearSaveDir { try saver.clear() }
        stubManager.stubSaver = config.saveResponses ? saver : nil
        
        try config.folders.forEach { folder in
            guard let stubCache = StubFolderCache(baseFolder: folder, filesManager: filesManager) else {
                throw StubPlayError.stubCacheLoad(nil, nil, folder)
            }
            stubManager.add(stubCache)
            do {
                try stubCache.load()
            } catch {
                throw StubPlayError.stubCacheLoad(error, stubCache, folder)
            }
        }
        
        try enableStub(isEnabledServer: config.isEnabledServer)
    }
    
    func disableStub() throws {
        try enableStub(false)
        stubManager.reset()
    }
}

extension StubPlay {
    func swizzleProtocolClasses() {
        let instance = URLSessionConfiguration.default
        
        let uRLSessionConfigurationClass: AnyClass = object_getClass(instance)!
        
        method_exchangeImplementations_safe(
            class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.protocolClasses)),
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.swizzle_protocolClasses))
        )
        method_exchangeImplementations_safe(
            class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.requestCachePolicy)),
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.swizzle_requestCachePolicy))
        )
        method_exchangeImplementations_safe(
            class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.urlCache)),
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.swizzle_urlCache))
        )
    }
}

extension URLSessionConfiguration {
    
    @objc func swizzle_protocolClasses() -> [AnyClass]? {
        guard var originalProtocolClasses = self.swizzle_protocolClasses() else {
            return [StubURLProtocol.self]
        }
        
        if !originalProtocolClasses.contains(where: { $0 == StubURLProtocol.self}) {
            originalProtocolClasses.insert(StubURLProtocol.self, at: 0)
        }
        return originalProtocolClasses
    }
    
    @objc func swizzle_requestCachePolicy() -> NSURLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }
    
    @objc func swizzle_urlCache() -> URLCache? {
        return nil
    }
    
}

private func method_exchangeImplementations_safe(_ m1: Method?, _ m2: Method?) {
    guard let m1 = m1, let m2 = m2 else { return }
    method_exchangeImplementations(m1, m2)
}
