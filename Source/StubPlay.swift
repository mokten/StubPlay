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

public class StubPlay {
    
    public static let `default` = StubPlay()
    
    private var isEnabled = false
    
    public func enableStub(_ enable: Bool = true) {
        guard isEnabled != enable else { return }
        isEnabled = enable
        
        if isEnabled {
            URLCache.shared.removeAllCachedResponses()
            URLProtocol.registerClass(StubURLProtocol.self)
        } else {
            URLProtocol.unregisterClass(StubURLProtocol.self)
        }
        
        swizzleProtocolClasses()
    }
}

public enum StubPlayError: LocalizedError {
    case stubCacheLoad(Error?, StubFolderCache?, String?)
}

public extension StubPlay {
    
    // Convenience helper
    func enableStub(for folders: [Folder], saveResponses: Bool = true, clearSaveDir: Bool = true, bundle: Bundle = Bundle.main) throws {
        enableStub()
        
        StubManager.shared.reset()
        let filesManager = FilesManager(bundle: bundle)
        let saver = StubFileSaver(filesManager: filesManager)
        if clearSaveDir { try saver.clear() }
        StubManager.shared.stubSaver = saveResponses ? saver : nil
        
        try folders.forEach { folder in
            guard let stubCache = StubFolderCache(baseFolder: folder, filesManager: filesManager) else {
                throw StubPlayError.stubCacheLoad(nil, nil, folder)
            }
            StubManager.shared.add(stubCache)
            do {
                try stubCache.load()
            } catch {
                throw StubPlayError.stubCacheLoad(error, stubCache, folder)
            }
        }
    }
    
    func disableStub() {
        enableStub(false)
        StubManager.shared.reset()
    }
}

private extension StubPlay {
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

private extension URLSessionConfiguration {
    
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
