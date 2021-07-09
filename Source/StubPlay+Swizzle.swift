//
//  StubPlay+Extension.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/3/20.
//  Copyright © 2020 Mokten Pty Ltd. All rights reserved.
//

import Foundation

public extension StubPlay {
    
    func swizzleProtocolClasses() {
        URLCache.shared.removeAllCachedResponses()
        URLProtocol.registerClass(StubURLProtocol.self)
        
        method_exchangeImplementations_safe(
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(getter: URLSession.shared.configuration.protocolClasses)),
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.swizzle_protocolClasses))
        )
        
        method_exchangeImplementations_safe(
            class_getClassMethod(URLSession.self, #selector(URLSession.init(configuration:delegate:delegateQueue:))),
            class_getClassMethod(URLSession.self, #selector(URLSession.swizzle_init(configuration:delegate:delegateQueue:)))
        )
        
        swizzleDefault()
        swizzleEphemeral()
    }
    
    func swizzleDefault() {
        method_exchangeImplementations_safe(
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.requestCachePolicy)),
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.swizzle_requestCachePolicy))
        )
        method_exchangeImplementations_safe(
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.urlCache)),
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.swizzle_urlCache))
        )
    }
    
    func swizzleEphemeral() {
        method_exchangeImplementations_safe(
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.requestCachePolicy)),
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.swizzle_ephemeral_requestCachePolicy))
        )
        method_exchangeImplementations_safe(
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.urlCache)),
            class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.swizzle_ephemeral_urlCache))
        )
    }
}

public extension URLSession {
    @objc dynamic static func swizzle_init(configuration: URLSessionConfiguration) -> Self {
        configuration.protocolClasses = swizzle_protocolClasses(configuration.protocolClasses)
        return self.swizzle_init(configuration: configuration)
    }
    
    @objc dynamic static func swizzle_init(configuration: URLSessionConfiguration,
                                           delegate: URLSessionDelegate?,
                                           delegateQueue queue: OperationQueue?) -> Self {
        configuration.protocolClasses = swizzle_protocolClasses(configuration.protocolClasses)
        return self.swizzle_init(configuration: configuration, delegate: delegate, delegateQueue: queue)
    }
}

private extension URLSession {
    static func swizzle_protocolClasses(_ protocolClasses: [AnyClass]?) -> [AnyClass]? {
        guard var originalProtocolClasses = protocolClasses else {
            return [StubURLProtocol.self]
        }
        
        if !originalProtocolClasses.contains(where: { $0 == StubURLProtocol.self}) {
            originalProtocolClasses.insert(StubURLProtocol.self, at: 0)
        }
        return originalProtocolClasses
    }
}

public extension URLSessionConfiguration {
    @objc dynamic class func swizzle_requestCachePolicy() -> NSURLRequest.CachePolicy { return .reloadIgnoringLocalCacheData }
    @objc dynamic class func swizzle_urlCache() -> URLCache? { return nil }
}

public extension URLSessionConfiguration {
    @objc func swizzle_protocolClasses() -> [AnyClass]? {
        guard var originalProtocolClasses = self.swizzle_protocolClasses() else {
            return [StubURLProtocol.self]
        }
        
        if !originalProtocolClasses.contains(where: { $0 == StubURLProtocol.self}) {
            originalProtocolClasses.insert(StubURLProtocol.self, at: 0)
        }
        return originalProtocolClasses
    }
}

public extension URLSessionConfiguration {
    @objc func swizzle_ephemeral_requestCachePolicy() -> NSURLRequest.CachePolicy { return .reloadIgnoringLocalCacheData }
    @objc func swizzle_ephemeral_urlCache() -> URLCache? { return nil }
}

public func method_exchangeImplementations_safe(_ m1: Method?, _ m2: Method?) {
    guard let m1 = m1, let m2 = m2 else { return }
    method_exchangeImplementations(m1, m2)
}
