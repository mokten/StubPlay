//
//
//  StubFolderCacheBodyDataTests.swift
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


class StubFolderCacheBodyDataTests: XCTestCase {
    
    private var filesManager: FilesManager!
    private var folder: StubFolderCache!
    
    override func setUp() {
        super.setUp()
        filesManager = FilesManager(bundle: Bundle(for: type(of: self)))
    }
    
    func testBodyData() throws {
        folder = StubFolderCache(baseFolder: "StubFolderCacheFiles/testBodyData", filesManager: filesManager)
        folder.load()
        let request = Request(method: .get, url: URL(string: "https://a.b/data.json")!)
        let stub = folder.get(request: request)
        let data = (stub?.responseData)!
        let body = String(data: data, encoding: .utf8)!
        XCTAssertEqual(body, "hiya\n")
    }
    
    func testBodyDataParams() throws {
        folder = StubFolderCache(baseFolder: "StubFolderCacheFiles/testBodyDataParams", filesManager: filesManager)
        folder.load()
        let request = Request(method: .get, url: URL(string: "https://a.com.au/offers/itunes-monthly?x=Y")!)
        let stub = folder.get(request: request)
        let data = (stub?.responseData)!
        let body = String(data: data, encoding: .utf8)!
        XCTAssertEqual(body, "oh yeah baby\n")
    }
    
    func testBodyDataPost() throws {
        folder = StubFolderCache(baseFolder: "StubFolderCacheFiles/testBodyData", filesManager: filesManager)
        folder.load()
        let request = Request(method: .post, url: URL(string: "https://a.com.au/au")!)
        let stub = folder.get(request: request)
        let data = (stub?.responseData)!
        let body = String(data: data, encoding: .utf8)!
        XCTAssertTrue(body.contains("access_token"))
    }
    
    
}
