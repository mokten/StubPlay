//
//
//  RewriteRuleTests.swift
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
@testable import StubPlay

class RewriteRuleMatchesTests: XCTestCase {
    
    func testMatches_host() {
        let rule = RewriteRule(method: nil, host: "localhost", path: nil, params: nil)
        let request = Request(method: .get, url: URL(string: "https://localhost"), headers:["h": "1"], body: "pretty")
        XCTAssertTrue(rule.matches(request))
    }
    
    func testMatches_host_false() {
        let rule = RewriteRule(method: nil, host: "localhost2", path: nil, params: nil)
        let request = Request(method: .get, url: URL(string: "https://localhost"), headers:["h": "1"], body: "pretty")
        XCTAssertFalse(rule.matches(request))
    }
    
    func testMatches_method() {
        let rule = RewriteRule(method: .get, host: nil, path: nil, params: nil)
        let request = Request(method: .get, url: URL(string: "https://localhost"), headers:["h": "1"], body: "pretty")
        XCTAssertTrue(rule.matches(request))
    }
    
    func testMatches_method_false() {
        let rule = RewriteRule(method: .post, host: nil, path: nil, params: nil)
        let request = Request(method: .get, url: URL(string: "https://localhost"), headers:["h": "1"], body: "pretty")
        XCTAssertFalse(rule.matches(request))
    }
    
    func testMatches_path() {
        let rule = RewriteRule(method: nil, host: nil, path: "/p", params: nil)
        let request = Request(method: .get, url: URL(string: "https://localhost/p"), headers:["h": "1"], body: "pretty")
        XCTAssertTrue(rule.matches(request))
    }
    
    func testMatches_path_long() {
        let rule = RewriteRule(method: nil, host: nil, path: "/p/q/r", params: nil)
        let request = Request(method: .get, url: URL(string: "https://localhost/p/q/r/s"), headers:["h": "1"], body: "pretty")
        XCTAssertFalse(rule.matches(request))
    }
    
    func testMatches_path_regex() {
        let rule = RewriteRule(method: nil, host: nil, path: "p/.*/s", params: nil)
        let request = Request(method: .get, url: URL(string: "https://localhost/p/qr/s"), headers:["h": "1"], body: "pretty")
        XCTAssertTrue(rule.matches(request))
    }
    
    func testMatches_path_false() {
        let rule = RewriteRule(method: nil, host: nil, path: "/p", params: nil)
        let request = Request(method: .get, url: URL(string: "https://localhost/o"), headers:["h": "1"], body: "pretty")
        XCTAssertFalse(rule.matches(request))
    }
    
    func testMatches_path_regex_false() {
        let rule = RewriteRule(method: nil, host: nil, path: "p/.*/a/s", params: nil)
        let request = Request(method: .get, url: URL(string: "https://localhost/p/qr/s"), headers:["h": "1"], body: "pretty")
        XCTAssertFalse(rule.matches(request))
    }
    
    func testMatches_params() {
        let rule = RewriteRule(method: nil, host: nil, path: nil, params: "a=1")
        let request = Request(method: .get, url: URL(string: "https://localhost/p?a=1&b=2"), headers: ["h": "1"], body: "pretty")
        XCTAssertFalse(rule.matches(request))
    }
    
    func testMatches_params_body() {
        let rule = RewriteRule(method: nil, host: nil, path: nil, params: "a=1")
        let request = Request(method: .post, url: URL(string: "https://localhost/p"), headers:["h": "1"], body: "a=1")
        XCTAssertTrue(rule.matches(request))
    }

    func testMatches_2() {
        let rule = RewriteRule(method: .get, host: nil, path: "/offers/itunes-monthly", params: "x=Y", body: "a=2")
        let request = Request(method: .get, url: URL(string: "https://a.com.au/offers/itunes-monthly?x=Y"), headers:["h": "1"], body: "a=1")
        XCTAssertFalse(rule.matches(request))
    }
    
    func testNamePostQuery() throws {
        let rule = RewriteRule(method: .post, host: nil, path: nil, params: nil, body: nil)
        let request = Request(method: .post, url: URL(string: "https://localhost.com"), headers:nil, body: "1234567890-98765432123456789098765432112345678900987654321")
        XCTAssertTrue(rule.matches(request))
    }
    
    func testNamePostNoQuery() throws {
        let rule = RewriteRule(method: .post, host: nil, path: nil, params: nil, body: "1234567890-98765432123456789098765432112345678900987654321")
        let request = Request(method: .post, url: URL(string: "https://localhost.com"), headers:nil, body: "1234567890-98765432123456789098765432112345678900987654321")
        XCTAssertTrue(rule.matches(request))
    }
}
