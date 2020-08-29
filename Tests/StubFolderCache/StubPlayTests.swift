//
//
//  StubPlayTests.swift
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

class StubPlayTests: XCTestCase {
    
    private let stubManager = StubManager.shared
    
    override func setUp() {
        super.setUp()
        do {
            try StubPlay.default.enableStub(for: StubConfig(folders: ["StubFolderCacheFiles/testBodyDataParams"], bundle: Bundle(for: type(of: self))))
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
            let request = Request(method: .get, url: URL(string: "https://a.com/offers/itunes-monthly?x=Y"),
                                  headers: ["Accept-Language": "en;q=1.0",
                "Accept-Encoding": "gzip;q=1.0, compress;q=0.5",
                "User-Agent": "Kayo/1.1.4 (au.com.streamotion.kayo; build:135; iOS 12.2.0) Alamofire/4.7.3"], body: nil)
            let stub = self.stubManager.get(request: request)
            if let data = stub?.bodyData {
                let body = String(data: data, encoding: .utf8)!
                XCTAssertEqual(body, "oh yeah baby\n")
            } else {
                XCTAssertFalse(true)
            }
            expec.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
}
