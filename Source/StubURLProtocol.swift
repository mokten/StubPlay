//
//
//  StubURLProtocol.swift
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

public class StubURLProtocol: URLProtocol {
    
    private enum CustomURLConst {
        static let requestHeaderKey = "StubPlayRequestHeader"
    }
    
    private lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }()
    
    private let stubManager = StubManager.shared
    private var dataTask: URLSessionDataTask?
    private var responseData: Data?
    
    // MARK: NSURLProtocol
    
    override public class func canInit(with request: URLRequest) -> Bool {
        
        if request.isWebSocket {
            logger("WEBSOCKET - never stubbed", request, request.allHTTPHeaderFields)
            return false
        }
        
        logger(request)
        return URLProtocol.property(forKey: CustomURLConst.requestHeaderKey, in: request as URLRequest) == nil
    }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override public func startLoading() {
        if let stubRequest = request.stubRequest, let stub = stubManager.get(request: stubRequest) {
            logger("MOCK:", request.url)
            finished(stub: stub, response: stub.httpURLResponse(defaultURL: request.url), bodyData: stub.bodyData, isCached: true)
            
        } else {
            logger("NETWORK:", request.url)
            guard let newRequest = request as? NSMutableURLRequest else { return }
            URLProtocol.setProperty(true, forKey: CustomURLConst.requestHeaderKey, in: newRequest)
             
            let dataTask = session.dataTask(with: newRequest as URLRequest)
            dataTask.resume()
            self.dataTask = dataTask
        }
    }
    
    override public func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
        responseData = nil
    }
}

extension StubURLProtocol: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        responseData = Data()
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        responseData?.append(data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        completionHandler(request)
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else { return }
        client?.urlProtocol(self, didFailWithError: error)
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
        finished(response: dataTask?.response, bodyData: responseData)
    }
}


extension StubURLProtocol: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
            
        } else {
            finished(response: dataTask?.response, bodyData: responseData)
        }
    }
}

private extension StubURLProtocol {
    func finished(response: URLResponse?, bodyData: Data?, isCached: Bool = false) {
        let stub = Stub(request: request, response: response as? HTTPURLResponse)
        finished(stub: stub, response: response, bodyData: bodyData, isCached: isCached)
    }
    
    func finished(stub: Stub?, response: URLResponse?, bodyData: Data?, isCached: Bool = false) {
        if let stub = stub, stub.skipSave != true {
            stubManager.save(stub, bodyData: bodyData)
        }
        
        guard let client = client else { return }
        defer { client.urlProtocolDidFinishLoading(self) }
        guard let response = response else { return }
        
        client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        if isCached, let data = bodyData {
            client.urlProtocol(self, didLoad: data)
        }
    }
    
}

private extension URLRequest {
    var isWebSocket: Bool {
        /**
         
         Reference header fields:
         Upgrade: websocket
         Connection: Upgrade
         Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
         Origin: http://example.com
         Sec-WebSocket-Protocol: chat, superchat
         Sec-WebSocket-Version: 13
         
         Reference: https://tools.ietf.org/html/rfc6455
         
         */
        return self.value(forHTTPHeaderField: "Upgrade")?.lowercased() == "websocket"
    }
}
