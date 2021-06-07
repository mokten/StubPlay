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

public final class StubURLProtocol: URLProtocol {
    
    private enum Constants {
        static let requestHeaderKey = "StubPlayRequestHeader"
    }
    
    private lazy var store: StubURLProtocolStorage = StubURLProtocolStore.shared
    
    var dataTask: URLSessionDataTask?
    var responseData: Data?
    
    // MARK: NSURLProtocol
    
    override public class func canInit(with request: URLRequest) -> Bool {
        
        if request.isWebSocket {
            logger("WEBSOCKET - never stubbed", request, request.allHTTPHeaderFields)
            return false
        }
        
        // logger(request)
        return URLProtocol.property(forKey: Constants.requestHeaderKey, in: request as URLRequest) == nil
    }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override public func startLoading() {
        if let stubRequest = request.stubRequest,
           let stub = store.get(request: stubRequest) {
            logger("MOCK:", request.url)
            store.finished(stub: stub,
                           urlProtocol: self,
                     response: stub.httpURLResponse(defaultURL: request.url),
                     bodyData: stub.responseData,
                     isCached: true)
            
        } else {
            logger("NETWORK:", request.url)
            guard let newRequest = request as? NSMutableURLRequest else { return }
            URLProtocol.setProperty(true, forKey: Constants.requestHeaderKey, in: newRequest)
            
            dataTask = store.dataTask(with: newRequest as URLRequest, urlProtocol: self)
            dataTask?.resume()
        }
    }
    
    override public func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
        responseData = nil
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
