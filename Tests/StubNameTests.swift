//
//  StubNameTests.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/5/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import XCTest
@testable import StubPlay

class StubNameTests: XCTestCase {
    
    func testNameGetHost() throws {
        let request = Request(method: .get, url: URL(string: "https://localhost.com/")!, headers:nil, body: nil)
        let stub = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(stub.name, "_")
    }
    
    func testGetPath() throws {
        let request = Request(method: .get, url: URL(string: "https://localhost.com/hello/dude")!, headers:nil)
        let stub = Stub(rewriteRule: nil, index: 0,  request: request, response: nil)
        XCTAssertEqual(stub.name, "hello_dude")
    }
    
    func testPostPath() throws {
        let request = Request(method: .post, url: URL(string: "https://localhost.com/hello/dude")!, headers:nil)
        let stub = Stub(rewriteRule: nil, index: 0,  request: request, response: nil)
        XCTAssertEqual(stub.name, "hello_dude")
    }
    
    func testNamePostQuery() throws {
        let request = Request(method: .post, url: URL(string: "https://localhost.com")!, headers:nil, body: "1234567890-98765432123456789098765432112345678900987654321")
        let stub = Stub(rewriteRule: nil, index: 0,  request: request, response: nil)
        XCTAssertEqual(stub.name, "_-7522882272664921009")
    }
    
    func testNamePostQueryAndBody() throws {
        let request = Request(method: .post, url: URL(string: "https://localhost.com?a=b")!, headers:nil, body: "1234567890-98765432123456789098765432112345678900987654321")
        let stub = Stub(rewriteRule: nil, index: 0,  request: request, response: nil)
        XCTAssertEqual(stub.name, "_a=b_-7522882272664921009")
    }
    
    func testNamePost() throws {
        let request = Request(method: .post, url: URL(string: "https://localhost.com?a=b")!, headers:nil)
        let stub = Stub(rewriteRule: nil, index: 0,  request: request, response: nil)
        XCTAssertEqual(stub.name, "_a=b")
    }
    
}
