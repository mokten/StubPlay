//
//  Bundle+Extensions.swift
//  Example-iOSUITests
//
//  Created by Yoo-Jin Lee on 12/7/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

private class TestClass {
    lazy var test = Bundle(for: type(of: self))
}

extension Bundle {
    static let uiTest = TestClass().test
}
