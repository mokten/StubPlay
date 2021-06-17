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

/*
 Represents a stubbed http request and response
 */
public struct Stub: Model {
    public var rewriteRule: RewriteRule?
    public var index: Int = 0
    public var skipSave: Bool?
    public var responseDataFileName: String?
    public var responseData: Data?
    public let request: Request
    public let response: Response?
}

public extension Stub {
    init(rewriteRule: RewriteRule? = nil, index: Int = 0, responseDataFileName: String? = nil, request: Request, response: Response?) {
        self.rewriteRule = rewriteRule
        self.index = index
        self.responseDataFileName = responseDataFileName
        self.responseData = nil
        self.request = request
        self.response = response
    }
    
    init?(request: URLRequest, response: HTTPURLResponse?) {
        guard let stubRequest = request.stubRequest else { return nil }
        self.rewriteRule = nil
        index = 0
        responseDataFileName = nil
        responseData = nil
        self.request = stubRequest
        self.response = response?.stubResponse
    }
}

public extension Stub {
    func httpURLResponse(defaultURL: URL?) -> HTTPURLResponse? {
        let url = request.url ?? defaultURL ?? URL(string: "https://stubplay.com/missing_url")!
        return HTTPURLResponse(url: url,
                               statusCode: response?.statusCode ?? 0,
                               httpVersion: "HTTP/1.1",
                               headerFields: (response?.headers) ?? [:])
    }
}

public extension HTTPURLResponse {
    var stubResponse: Response {
        var headers: [String: String] = [:]
        for (key, value) in self.allHeaderFields {
            headers["\(key)"] = "\(value)"
        }
        
        return Response(statusCode: statusCode, mimeType: mimeType, headers: headers, bodyUrl: nil)
    }
}

