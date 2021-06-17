//
//  RewriteRule+Matches.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/5/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

extension RewriteRule {
    static func doesNotMatch(key: String?, matcher: String?) -> Bool {
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
        
        if let host = host {
            if RewriteRule.doesNotMatch(key: host, matcher: requestUrl.host) { return false }
        }
        
        if let path = path {
            if RewriteRule.doesNotMatch(key: path, matcher: requestUrl.path) { return false }
        }
        
        if let params = params {
            if RewriteRule.doesNotMatch(key: params, matcher: requestUrl.query) { return false }
        }
        
        if let body = body {
            if RewriteRule.doesNotMatch(key: body, matcher: request.body) { return false }
        }
        
        return true
    }
}
