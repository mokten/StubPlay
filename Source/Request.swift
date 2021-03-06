//
//  Request.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/5/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

public struct Request: Model {
    public let method: HttpMethod
    public let url: URL
    public let headers: [String: String]?
    public var body: String?
    
    public var rewriteRule: RewriteRule {
        return RewriteRule(method: method, host: nil, path: url.path, params: url.query, body: body)
    }
    
    public init(method: HttpMethod = .get, url: URL, headers: [String : String]? = nil, body: String? = nil) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
    }
}

extension Request {
    
}
