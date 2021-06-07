//
//  Response.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/5/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

public struct Response: Model {
    public let statusCode: Int?
    public let mimeType: String?
    public let headers: [String: String]?
    public var bodyUrl: String?
}
