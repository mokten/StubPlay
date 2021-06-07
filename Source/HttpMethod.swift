//
//  HttpMethod.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/5/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

public enum HttpMethod: String, Model {
    case get, post, delete, put, head, options, trace, patch, connect
}
