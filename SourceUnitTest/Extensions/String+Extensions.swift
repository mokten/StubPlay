//
//  String+Extensions.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 9/7/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

extension String {
    var contents: String {
        let url = Bundle.test.url(forResource: self, withExtension: nil)!
        let data = FileManager.default.contents(atPath: url.path)!
        return String(data: data, encoding: .utf8)!
    }
}
