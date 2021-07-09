//
//
//  MessageSaveTests.swift
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

class StubTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? StubPlay.default.start(with: StubConfig(
                                        globalConfig: "StubFiles/.config",
                                        folders: ["StubFiles"],
                                        clearSaveDir: true,
                                        bundle: Bundle(for: type(of: self)),
                                        isEnabledServer: false,
                                        isLogging: false))
    }
    
    func testEncodeDecode() throws {
        let bodyUrl = "https://httpbin.org/get"
        let rule = RewriteRule(method: .post, host: "httpbin.org", path: "hi", params: nil)
        let response = Response(statusCode: 200, mimeType: "application/json", headers: ["hi" : "ho"], bodyUrl: bodyUrl)
        let request = Request(method: .get, url: URL(string: "https://httpbin.org/get")!, headers: ["wwdc" : "gogo"], body: "some url")
        let msg = Stub(rewriteRule: rule, request: request, response: response)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(msg)
        let decoder = JSONDecoder()
        let returnedMsg = try decoder.decode(Stub.self, from: data)
        XCTAssertEqual(returnedMsg, msg)
    }
    
    func testPost() throws {
        let exp = expectation(description: "Success")
        
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: URL(string: "https://google.com/")!)
        request.httpMethod = "POST"
        request.httpBody = "yahooo".data(using: .utf8)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                XCTAssertNotNil("\(error)")
            }
            let str = String(data: data!, encoding: .utf8)
            XCTAssertEqual("gotcha\n", str)
            
            exp.fulfill()
        }
        task.resume()
        
        waitForExpectations(timeout: 123123123, handler: nil)
    }
    
}
