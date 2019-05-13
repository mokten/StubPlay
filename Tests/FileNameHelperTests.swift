//
//
//  MessageTests.swift
//
//  Copyright © 2019 Mokten Pty Ltd. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import XCTest

#if os(iOS)
@testable import StubPlay_iOS
#else
@testable import StubPlay_tvOS
#endif

class FileNameHelperTests: XCTestCase {
    private let filenameHelper = DefaultFileNameHelper()
    
    func testFileName_path() {
        let request = Request(method: .get, url: URL(string: "https://localhost"), headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.fileName(for: msg), "_.get.0.json")
    }
    
    func testFileName_path_() {
        let request = Request(method: .get, url: URL(string: "https://localhost/?"), headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.fileName(for: msg), "_.get.0.json")
    }
    
    func testFileName_path_a() {
        let request = Request(method: .get, url: URL(string: "https://localhost/?a"), headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.fileName(for: msg), "_a.get.0.json")
    }
    
    func testFileName_path_long() {
        let request = Request(method: .get, url: URL(string: "https://localhost/a/b/c"), headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.fileName(for: msg), "a_b_c.get.0.json")
    }
    func testFileName_path_long2() {
        let request = Request(method: .get, url: URL(string: "https://localhost/a/b/c/?d=e"), headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.fileName(for: msg), "a_b_c_d=e.get.0.json")
    }
    
    func testFileName_path_query() {
        let request = Request(method: .get, url: URL(string: "https://localhost?a=b"), headers: nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.fileName(for: msg), "_a=b.get.0.json")
    }
    
    func testFileName_path_ext() {
        let request = Request(method: .get, url: URL(string: "http://a.b/data.json"), headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.fileName(for: msg), "data_json.get.0.json")
    }
    
    func testFileName_path_noresponse() {
        let request = Request(method: .get, url: URL(string: "https://a.b/noreponse"), headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.fileName(for: msg), "noreponse.get.0.json")
    }
    
    func testFileName_path_query_unsafe() {
        let request = Request(method: .get, url: URL(string: "https://localhost?a=[/* <>?%|.:"), headers: nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.fileName(for: msg), "_.get.0.json")
    }
    
}