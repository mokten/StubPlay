//
//  Response.swift
//
//  Copyright (c) 2019 Mokten Pty Ltd
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

public protocol Model: Codable, Hashable { }

public struct Stub: Model {
    public let rewriteRule: RewriteRule?
    public var index: Int
    public var bodyFileName: String? = nil
    public var bodyData: Data?
    public let request: Request
    public let response: Response?
    
    public init(rewriteRule: RewriteRule? = nil, index: Int = 0, bodyFileName: String? = nil, request: Request, response: Response?) {
        self.rewriteRule = rewriteRule
        self.index = index
        self.bodyFileName = bodyFileName
        self.bodyData = nil
        self.request = request
        self.response = response
    }
    
    public init?(request: URLRequest, response: HTTPURLResponse?) {
        guard let stubRequest = request.stubRequest else { return nil }
        self.rewriteRule = nil
        index = 0
        bodyFileName = nil
        bodyData = nil
        self.request = stubRequest
        self.response = response?.stubResponse
    }
}

public struct RewriteRule: Model {
    public let method: HttpMethod?
    public let host: String?
    public let path: String?
    public let params: String?
}

extension RewriteRule {
    private func doesNotMatch(key: String?, matcher: String?) -> Bool {
        guard let key = key else { return false }
        if key.contains("*") {
            if let matcher = matcher, matcher.range(of: key, options: .regularExpression) == nil {  return true }
        } else {
            if let matcher = matcher, matcher != key { return true }
        }
        return false
    }
    
    public func matches(_ request: Request) -> Bool {
        guard let requestUrl = request.url else { return false }
        
        if let method = method {
            guard request.method == method else { return false }
        }
        
        
        if doesNotMatch(key: host, matcher: requestUrl.host) { return false }
        if doesNotMatch(key: path, matcher: requestUrl.path) { return false }
        
        
//        if let host = host {
//            if host.contains("*") {
//                if let requestHost = requestUrl.host, requestHost.range(of: host, options: .regularExpression) == nil {  return false }
//            } else {
//                if let requestHost = requestUrl.host, requestHost != host { return false }
//            }
//        }
        
//        if let path = path {
//                if requestUrl.path.range(of: path, options: .regularExpression) == nil { return false }
//
//        }
        
        if let params = params {
            if doesNotMatch(key: params, matcher: requestUrl.query) { return false }
            if doesNotMatch(key: params, matcher: request.body) { return false }
            
//            if let requestQuery = requestUrl.query {
//                if requestQuery.range(of: params, options: .regularExpression) == nil { return false }
//            }
//            if let requestBody = request.body {
//                if requestBody.range(of: params, options: .regularExpression) == nil { return false }
//            }
        }
        
        return true
    }
}

public enum HttpMethod: String, Model {
    case get, post, delete, put, head, options, trace, patch, connect
}

public struct Request: Model {
    public let method: HttpMethod
    public let url: URL?
    public let headers: [String: String]?
    public let body: String?
    
    public var rewriteRule: RewriteRule {
        let params: String?
        
        if method == .get {
            params = url?.query
        } else {
            params = body
        }
        
        return RewriteRule(method: method, host: nil, path: url?.path, params: params)
    }
}

public struct Response: Model {
    public let statusCode: Int?
    public let mimeType: String?
    public let headerFields: [String: String]?
    public var bodyUrl: String?
}


public extension URLRequest {
    var stubRequest: Request? {
        guard let url = url else { return nil }
        
        let method: HttpMethod
        if let httpMethod = httpMethod?.lowercased() {
            method = HttpMethod(rawValue: httpMethod) ?? .get
        } else {
            method = .get
        }
        
        // TODO: Check image/count max ?
        let body: String?
        if let httpBody = httpBody, httpBody.count > 0 {
            body = String(data: httpBody, encoding: .utf8)
        } else {
            body = nil
        }
        
        return Request(method: method, url: url, headers: self.allHTTPHeaderFields, body: body)
    }
}

public extension Stub {
    var httpURLResponse: HTTPURLResponse? {
        guard let url = request.url else { return nil }
        return HTTPURLResponse(url: url,
                               statusCode: response?.statusCode ?? 0,
                               httpVersion: "HTTP/1.1",
                               headerFields: (response?.headerFields) ?? [:])
    }
}

public extension HTTPURLResponse {
    var stubResponse: Response {
        var headerFields: [String: String] = [:]
        for (key, value) in self.allHeaderFields {
//            if let keyStr = "\(key)" as? String {
//                if let keyStrLower = keyStr.lowercased as? String {
//                    if "cache-control" == keyStrLower || "expires" == keyStrLower {
//                        continue
//                    }
//                }
                
                headerFields["\(key)"] = "\(value)"
//            }
        }
        
        headerFields["Cache-Control" ] = nil
        headerFields["Expires" ] = nil
        
        return Response(statusCode: statusCode, mimeType: mimeType, headerFields: headerFields, bodyUrl: nil)
    }
}
