//
//  FolderConfig.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 17/6/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

/*
 
 Configuration rules for saving stubs

 Match precedence is in the following order:
   1. rewriteRule
 
 */
public struct StubRewriteRules: Model {
    /// When saving the stub, will add the first matched rule
    public let rewriteRule: [RewriteRule]?
}
