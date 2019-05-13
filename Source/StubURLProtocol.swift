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
        return URLProtocol.property(forKey: CustomURLConst.requestHeaderKey, in: request as URLRequest) == nil
    }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override public func startLoading() {
        
        if let stubRequest = request.stubRequest, let stub = stubManager.get(request: stubRequest) {
            logger("MOCK: ", request.url!)
            
            
            if request.url?.absoluteString.contains("itunes-monthly") == true {
                logger("mock: ", stub.bodyData?.count)
            }
            
            finished(stub: stub, response: stub.httpURLResponse, bodyData: stub.bodyData, isCached: true)
            
        } else {
            logger("NETWORK: ", request.url!)
//            fatalError()
            
            let newRequest = request as! NSMutableURLRequest
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
        if let stub = stub {
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

// MARK: - Logger

private extension Array {
    var debugDescription: String {
        return description
    }
    var description: String {
        return "\"\(self.count): \(self)\""
    }
}

private extension Dictionary {
    var debugDescription: String {
        return description
    }
    var description: String {
        let dict = self
        let startStr = "\n [\(dict.count): "
        let str = dict.reduce(startStr) { (result, arg1) -> String in
            let (key, value) = arg1
            let strValue: String
            if let v = value as? CustomStringConvertible {
                strValue = v.description
            } else {
                strValue = "\(value)"
            }
            return result + "\"\(key)\"=\"\(strValue)\",\n\t"
        }
        return str.prefix(str.count - 3) + "]"
    }
}

enum Logger {
    static func debug(_ obj: Any) -> String {
        var str = String()
        dump(obj, to: &str)
        return str
    }
    
    static func description(_ obj: Any?) -> String {
        if let d = obj as? [AnyHashable: Any] {
            return d.description
            //             return "\(d)"
        } else if let dict = obj as? [AnyHashable: Any] {
            return dict.description
            //            return "\(dict)"
        }
        
        guard let o = obj as? [AnyHashable: Any] else {
            if let arg = obj {
                return "\"\(arg)\""
            } else {
                return String(describing: obj)
            }
        }
        
        return debug(o)
    }
}

public func logger(_ items: Any?..., separator: String = " ", terminator: String = "\n", _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if !DISABLE_LOG
    
    struct Log {
        static let dtFmt: DateFormatter = {
            let dtFmt = DateFormatter()
            dtFmt.dateFormat = "HH:mm:ss.SSS"
            return dtFmt
        }()
        
        static func currentFileName(_ fileName: String = #file) -> String {
            var str = String(describing: fileName)
            if let idx = str.range(of: "/", options: .backwards)?.upperBound {
                str = String(str[idx...])
            }
            if let idx = str.range(of: ".", options: .backwards)?.lowerBound {
                str = String(str[..<idx])
            }
            return str
        }
    }
    
    let stringItem = items.map { Logger.description($0) } .joined(separator: separator)
    
    print("\(Log.dtFmt.string(from: Date())) \(Log.currentFileName(file)).\(function)[\(line)]: \(stringItem)", terminator: terminator)
    #endif
}

