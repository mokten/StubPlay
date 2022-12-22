//
//  StubResourceLoaderStore.swift
//  StubPlay
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

public protocol StubResourceLoaderStorable {
//    func get(request: Request) -> Stub?
//
//    func dataTask(with request: URLRequest, urlProtocol: StubURLProtocol) -> URLSessionDataTask
//
//    func finished(stub: Stub?, urlProtocol: URLProtocol, response: URLResponse?, bodyData: Data?, isCached: Bool)
}

public final class StubResourceLoaderStore: NSObject {
    static let shared = StubResourceLoaderStore()
    
    private lazy var defaultSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = true
        config.timeoutIntervalForResource = 3600
        if #available(iOS 11.0, *) {
            if #available(macOS 10.13, *) {
                config.waitsForConnectivity = true
            }
        }
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    private lazy var session: URLSession = defaultSession
    
    private let stubManager = StubManager.shared
    
    private(set) var avPlayerResourceLoader: AssetResourceLoader!
    
    public func update(config: URLSessionConfiguration?, stubManager: StubManager, port: Int) {
        guard let config = config else {
            session = defaultSession
            avPlayerResourceLoader = AssetResourceLoader(session: session, stubManager: stubManager, port: port)
            return
        }
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        avPlayerResourceLoader = AssetResourceLoader(session: session, stubManager: stubManager, port: port)
    }
}

extension StubResourceLoaderStore: StubResourceLoaderStorable {
    
}

extension StubResourceLoaderStore: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(request)
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let protectionSpace = challenge.protectionSpace
        let sender = challenge.sender
        
        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                sender?.use(credential, for: challenge)
                completionHandler(.useCredential, credential)
                return
            }
        }
        
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
}
