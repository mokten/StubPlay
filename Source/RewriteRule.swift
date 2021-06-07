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
    public let host: String?
    public let path: String?
    public let params: String?
    public var body: String?
}
