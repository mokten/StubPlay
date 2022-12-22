//
//
//  StubURLProtocolTests.swift
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

class StubURLProtocolTests: XCTestCase {
    
    private let urls = [
//        "https://a.b/data.json",
//        "https://a.b/noreponse",
//        "https://a.com/image/block.png"
        
        "https://www.google.com/"
    ]
    
    override func setUp() {
        super.setUp()
        do {
            try StubPlay.default.start(with: StubConfig(folders: ["StubURLProtocolFiles/testStubRequest"],
                                                        saveResponsesDirURL: nil,
                                                        validateResponseFile: false,
                                                        bundle: Bundle.test,
                                                        isEnabledServer: false,                                                        
                                                        isLogging: true)
            )
        } catch {
            XCTAssertTrue(false, error.localizedDescription)
        }
    }
    
    func testStubRequest() throws {
        urls.forEach { _testStubRequest(urlStr: $0) }
    }
    
    func _testStubRequest(urlStr: String) {
        let exp = expectation(description: "Success")
        guard let url = URL(string: urlStr) else { return XCTAssertTrue(false, "\(urlStr)") }
        
        let config = URLSessionConfiguration.default

        if #available(iOS 11.0, *) {
            config.multipathServiceType = .handover
        }

        _ = config.enableStub(true)
        let session = URLSession(configuration: config)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        if #available(iOS 14.5, *) {
            request.assumesHTTP3Capable = true
        }
        let task = session.dataTask(with: request) { data, response, error in
            XCTAssertNil(error)
            XCTAssertNotNil(data)
            exp.fulfill()
        }
        
        task.resume()
        waitForExpectations(timeout: 1) { error in
            guard let error = error else { return }
            fatalError("Timeout \(urlStr), \(String(describing: error))")
        }
    }

}
