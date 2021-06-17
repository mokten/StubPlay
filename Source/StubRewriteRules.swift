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

 */
public struct StubRewriteRules: Model {

    /// When saving the stub, will add the first matched rule
    public let addToSavedStubRules: [RewriteRule]?
    
    /// Will not save the Stub if there is a matched rule
    public let doNotSaveStubRules: [RewriteRule]?
}
