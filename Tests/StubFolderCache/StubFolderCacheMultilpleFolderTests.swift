//
//
//  StubFolderCacheMultilpleFolderTests.swift
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

class StubFolderCacheMultilpleFolderTests: XCTestCase {
    private let stubManager = StubManager.shared
    
    override func setUp() {
        super.setUp()
        do {
            let folders = ["StubFolderCacheFiles/testMultipleFolders/folder1", "StubFolderCacheFiles/testMultipleFolders/folder2"]
            try StubPlay.default.enableStub(for: StubConfig(folders: folders, bundle: Bundle(for: type(of: self))))
        } catch {
            XCTAssertTrue(false)
        }
    }
    
    func testBodyDataParams() throws {
        measure {
            do { try self._testBodyDataParams() } catch { XCTAssertTrue(false) }
        }
    }
    
    
    func _testBodyDataParams() throws {
        let expec = expectation(description: "")
        
        DispatchQueue.main.async {
            let request = Request(method: .get, url: URL(string: "https://a.b/data.json"), headers: nil, body: nil)
            let stub1 = self.stubManager.get(request: request)
            let body1 = String(data: (stub1?.responseData)!, encoding: .utf8)!
            XCTAssertEqual(body1, "I am in folder1\n")
            
            let stub1b = self.stubManager.get(request: request)
            let body1b = String(data: (stub1b?.responseData)!, encoding: .utf8)!
            XCTAssertEqual(body1b, "I am in folder1\n")
            
            
            let request2 = Request(method: .get, url: URL(string: "https://a.b/data2.json"), headers: nil, body: nil)
            let stub2 = self.stubManager.get(request: request2)
            let body2 = String(data: (stub2?.responseData)!, encoding: .utf8)!
            XCTAssertEqual(body2, "I am data2 and in folder2\n")
            
            expec.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
}
