//
//  StubAssert.swift
//  
//  Created by Yoo-Jin Lee on 12/10/2022.
//

import XCTest
import StubPlay

extension XCTest {
    public static func StubYLEE(_ expression: @autoclosure () throws -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) throws {
        print(try expression())
    }
}
