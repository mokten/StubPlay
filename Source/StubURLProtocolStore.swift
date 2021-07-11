//
//  StubURLStore.swift
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

public protocol StubURLProtocolStorage {
    func get(request: Request) -> Stub?
    
    func dataTask(with request: URLRequest, urlProtocol: StubURLProtocol) -> URLSessionDataTask
    
    func finished(stub: Stub?, urlProtocol: URLProtocol, response: URLResponse?, bodyData: Data?, isCached: Bool)
}

public final class StubURLProtocolStore: NSObject {
    static let shared = StubURLProtocolStore()
    
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
    
    @Atomic
    private var cache = NSMapTable<URLSessionTask, StubURLProtocol>.init(
        keyOptions: .weakMemory,
        valueOptions: .weakMemory
    )
    
    @discardableResult
    public func updateSession(config: URLSessionConfiguration?) -> URLSession {
        guard let config = config else {
            session = defaultSession
            return session
        }
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return session
    }
}

extension StubURLProtocolStore: StubURLProtocolStorage {
    public func get(request: Request) -> Stub? {
        return stubManager.get(request: request)
    }
    
    public func dataTask(with request: URLRequest, urlProtocol: StubURLProtocol) -> URLSessionDataTask {
        let dataTask = session.dataTask(with: request)
        cache.setObject(urlProtocol, forKey: dataTask)
        return dataTask
    }
    
    public func finished(stub: Stub?, urlProtocol: URLProtocol, response: URLResponse?, bodyData: Data?, isCached: Bool = false) {
          
        if let stub = stub, stub.skipSave != true {
            stubManager.save(stub, bodyData: bodyData)
        }
        
        guard let client = urlProtocol.client else {
            return
        }
        
        if isCached, let response = response {
            client.urlProtocol(urlProtocol, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = bodyData {
                client.urlProtocol(urlProtocol, didLoad: data)
            }
        }
        
        client.urlProtocolDidFinishLoading(urlProtocol)
    }
}

extension StubURLProtocolStore: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let urlProtocol = cache.object(forKey: dataTask) else {
            return
        }
        
        urlProtocol.client?.urlProtocol(urlProtocol, didReceive: response, cacheStoragePolicy: .notAllowed)
        urlProtocol.responseData = Data()
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let urlProtocol = cache.object(forKey: dataTask) else {
            return
        }
        urlProtocol.client?.urlProtocol(urlProtocol, didLoad: data)
        urlProtocol.responseData?.append(data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(request)
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else { return }
        _cache.mutate { cache in
            guard let enumerator = cache.objectEnumerator() else { return }
            while let urlProtocol = enumerator.nextObject() as? StubURLProtocol {
                urlProtocol.client?.urlProtocol(urlProtocol, didFailWithError: error)
            }
            cache.removeAllObjects()
        }
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
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        _cache.mutate { cache in
            guard let enumerator = cache.objectEnumerator() else { return }
            while let urlProtocol = enumerator.nextObject() as? StubURLProtocol {
                urlProtocol.client?.urlProtocolDidFinishLoading(urlProtocol)
            }
            cache.removeAllObjects()
        }
    }
}


extension StubURLProtocolStore: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        _cache.mutate { cache in
            
            if let error = error {
                guard let urlProtocol = cache.object(forKey: task) else {
                    return
                }
                urlProtocol.client?.urlProtocol(urlProtocol, didFailWithError: error)
            } else {
                guard let urlProtocol = cache.object(forKey: task) else {
                    return
                }
                finished(urlProtocol: urlProtocol, response: task.response, bodyData: urlProtocol.responseData)
            }
            cache.removeObject(forKey: task)
        }
    }
}

private extension StubURLProtocolStore {
    func finished(urlProtocol: StubURLProtocol?, response: URLResponse?, bodyData: Data?, isCached: Bool = false) {
        guard let urlProtocol = urlProtocol else { return }
        let stub = Stub(request: urlProtocol.request, response: urlProtocol.dataTask?.response as? HTTPURLResponse)
        finished(stub: stub, urlProtocol: urlProtocol, response: response, bodyData: bodyData, isCached: isCached)
    }
}
