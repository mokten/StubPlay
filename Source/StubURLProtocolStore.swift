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

    private var saveMetrics: Bool = false
    
    @Atomic
    private var taskProtocolCache = NSMapTable<URLSessionTask, StubURLProtocol>.init(
        keyOptions: .weakMemory,
        valueOptions: .weakMemory
    )
    
    @discardableResult
    public func updateSession(config: URLSessionConfiguration?, saveMetrics: Bool = true) -> URLSession {
        self.saveMetrics = saveMetrics
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
        taskProtocolCache.setObject(urlProtocol, forKey: dataTask)
        return dataTask
    }
    
    public func finished(stub: Stub?, urlProtocol: URLProtocol, response: URLResponse?, bodyData: Data?, isCached: Bool = false) {
        logger()
          
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
        guard let urlProtocol = taskProtocolCache.object(forKey: dataTask) else {
            return
        }
        
        urlProtocol.client?.urlProtocol(urlProtocol, didReceive: response, cacheStoragePolicy: .notAllowed)
        urlProtocol.responseData = Data()
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let urlProtocol = taskProtocolCache.object(forKey: dataTask) else {
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
        _taskProtocolCache.mutate { cache in
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
        _taskProtocolCache.mutate { cache in
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
        _taskProtocolCache.mutate { cache in
            logger()
            
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

    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        logger()
        
        /**
         iCloud Private Relay can change the timing and sequence of events for your tasks by sending requests through a set of privacy proxies. All tasks that use iCloud Private Relay set the isProxyConnection property in their transaction metrics. In this case, the remoteAddress property contains the address of the proxy, and not the origin server.

         Tasks to different hosts can reuse the same transport connection, just like how tasks can already share a connection when using HTTP/2. In these cases, a proxied task may not report any secureConnectionStartDate or secureConnectionEndDate.
         
         */
        if #available(iOS 13.0, *), saveMetrics {
            logger("\(task.currentRequest?.url?.absoluteString ?? "")\n taskInterval=", metrics.taskInterval.duration, "redirectCount=", metrics.redirectCount)
        
            for metric in metrics.transactionMetrics {
                print(metric.details
                      ,"\n", metric
                )
            }
        }
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension URLSessionTaskTransactionMetrics {
    
    public var details: String {
        "Protocol: \(negotiatedTLSProtocolVersion?.description ?? "")\n"
        + "NetworkProtocolName: \(self.networkProtocolString)\n"
        + "Using Proxy: \(self.isProxyConnection)\n"
        + "Total Time: \(Date.distance(fetchStartDate, to: responseEndDate) ?? -1)\n"
        + " DNS Lookup: \(Date.distance(domainLookupStartDate, to: domainLookupEndDate) ?? -1)\n"
        + " TCP: \(Date.distance(connectStartDate, to: secureConnectionStartDate) ?? -1)\n"
        + " TLS: \(Date.distance(secureConnectionStartDate, to: secureConnectionEndDate) ?? -1)\n"
        + " Request: \(Date.distance(requestStartDate, to: requestEndDate) ?? -1)\n"
        + " HTTP: \(Date.distance(requestEndDate, to: responseStartDate) ?? -1)\n"
        + " Response: \(Date.distance(responseStartDate, to: responseEndDate) ?? -1)\n"
    }
    
    /// https://www.iana.org/assignments/tls-extensiontype-values/tls-extensiontype-values.xhtml
    public var networkProtocolString: String {
        guard let networkProtocolName = networkProtocolName else { return "" }
        switch networkProtocolName {
        case "stun.turn": return "Traversal Using Relays around NAT (TURN)"
        case "stun.nat-discovery": return "STUN"
        case "h2": return "HTTP/2 over TLS"
        case "h2c": return "HTTP/2 over TCP"
        case "webrtc": return "WebRTC Media and Data"
        case "c-webrtc": return "Confidential WebRTC Media and Data"
        case "managesieve": return "ManageSieve"
        case "coap": return "CoAP"
        case "XMPP jabber:client namespace": return "xmpp-client"
        case "XMPP jabber:server namespace": return "xmpp-server"
        case "DNS-over-TLS": return "dot"
        case "h3": return "HTTP/3"
        case "smb": return "SMB2"
        default: return networkProtocolName.uppercased()
        }
    }
}

extension Date {
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    static func distance(_ from: Date?, to: Date?) -> TimeInterval? {
        guard let from = from, let to = to else { return nil }
        return from.distance(to: to)
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension tls_protocol_version_t: CustomDebugStringConvertible {
    public var debugDescription: String {
        description
    }
    
    public var description: String {
        switch self {
        case .TLSv10: return "TLS 1.0"
        case .TLSv11: return "TLS 1.1"
        case .TLSv12: return "TLS 1.2"
        case .TLSv13: return "TLS 1.3"
        case .DTLSv10: return "DTL 1.0"
        case .DTLSv12: return "DTL 1.2"
        @unknown default: return "unknown"
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
