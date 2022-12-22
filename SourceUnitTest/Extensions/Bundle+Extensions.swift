//
//  Bundle+Extensions.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 9/7/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

private class TestClass {
    lazy var test = Bundle(for: type(of: self))
}

extension Bundle {
    static let test = TestClass().test
    
    /// Returns the project directory
    /// 
    /// Requires PROJECT_DIR to be set in Info.plist PROJECT_DIR = $(PROJECT_DIR)
    static let projectDir = test.infoDictionary!["PROJECT_DIR"] as? String
}
