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

import Foundation
import XCTest
@testable import StubPlay

class FilenameFormatterTests: XCTestCase {
    private let filenameHelper = DefaultFilenameFormatter()

    func testFunctionSafeFileName() throws {
        XCTAssertEqual(#function.safeFileName(replaceWith: ""), "testFunctionSafeFileName")
    }
    
    func testFileNameSlash_path() {
        let request = Request(method: .get, url: URL(string: "https://localhost/")!, headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.filename(for: msg), "_.get.0.json")
    }
    
    func testFileName_path() {
        let request = Request(method: .get, url: URL(string: "https://localhost")!, headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.filename(for: msg), "_.get.0.json")
    }
    
    func testFileName_path_() {
        let request = Request(method: .get, url: URL(string: "https://localhost/?")!, headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.filename(for: msg), "_.get.0.json")
    }
    
    func testFileName_path_a() {
        let request = Request(method: .get, url: URL(string: "https://localhost/?a")!, headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.filename(for: msg), "_a.get.0.json")
    }
    
    func testFileName_path_long() {
        let request = Request(method: .get, url: URL(string: "https://localhost/a/b/c")!, headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.filename(for: msg), "a_b_c.get.0.json")
    }
    func testFileName_path_long2() {
        let request = Request(method: .get, url: URL(string: "https://localhost/a/b/c/?d=e")!, headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.filename(for: msg), "a_b_c_d=e.get.0.json")
    }
    
    func testFileName_path_query() {
        let request = Request(method: .get, url: URL(string: "https://localhost?a=b")!)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.filename(for: msg), "_a=b.get.0.json")
    }
    
    func testFileName_path_ext() {
        let request = Request(method: .get, url: URL(string: "http://a.b/data.json")!, headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.filename(for: msg), "data_json.get.0.json")
    }
    
    func testFileName_path_noresponse() {
        let request = Request(method: .get, url: URL(string: "https://a.b/noreponse")!, headers:nil, body: nil)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.filename(for: msg), "noreponse.get.0.json")
    }
    
    func testFileName_path_query_unsafe() {
        var comp = URLComponents(string: "https://abc.com")!
        comp.queryItems = [URLQueryItem(name: "a", value: "[/* <>?%|.:")]
        let request = Request(method: .get, url: comp.url!)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertEqual(filenameHelper.filename(for: msg), "_a=_5B___20_3C_3E__25_7C__.get.0.json")
    }
    
    func testFileName_query() {
        let url = URL(string: "https://msg.corelogic.asia/property/search/AU/rppiphone?addressSuburbStatePostcode=Englorie%20Park%20NSW%202560&offset=1&limit=50")!
            let request = Request(method: .get, url: url)
            let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
            XCTAssertEqual(filenameHelper.filename(for: msg), "property_search_AU_rppiphone_addressSuburbStatePostcode=Englorie_20Park_20NSW_202560&offset=1&limit_-8563436252288307235.get.0.json")
    }
    
    func testFileNameShorten() {
        let url = "https://localhost/asdf/bsadfs/avssdsdfsd/fsdfsadf/sdvsdvsdv/asdfsadfs?asdffdsaf=sdfsavdsdsfsdf&sadfsadfsadfvjyh=vfddvsdafsdjfhjskdfhjksdhfjkasdf&vdnjksdavbksadbvjhsdpwewrasdfsadfsdf&dsavsdvbsjdvbjshdc,xsfwer=qwertyewrtewwrtqwert"
        let request = Request(method: .get, url: URL(string: url)!)
        let msg = Stub(rewriteRule: nil, index: 0, request: request, response: nil)
        XCTAssertTrue(filenameHelper.filename(for: msg).count <= 131)
    }
}
