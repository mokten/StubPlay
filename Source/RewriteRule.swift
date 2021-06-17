//
//  RewriteRule.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/5/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

public struct RewriteRule: Model {
    
    public let method: HttpMethod?
    
    /*
     url host
     
     for example:
     With the following url:
        https://abc.com/d/e?f=g
     
     the host is:
        abc.com
     
     */
    public let host: String?
    
    /*
     url path
     
     for example:
     With the following url:
        https://abc.com/d/e?f=g
     
     the path is:
        /d/e
     
     */
    public let path: String?
    
    /*
     url params
     
     for example:
     With the following url:
        https://abc.com/d/e?f=g
     
     the params is:
        f=g
     
     */
    public let params: String?
    
    public var body: String?
}
