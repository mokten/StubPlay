//
//  StubPlay+Extension.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/3/20.
//  Copyright © 2020 Mokten Pty Ltd. All rights reserved.
//

import Foundation

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
