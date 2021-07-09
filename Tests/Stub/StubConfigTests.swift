//
//  StubTests+Config.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 23/6/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import XCTest
@testable import StubPlay

class StubConfigTests: XCTestCase {

    override func setUp() {
        super.setUp()
        print(FilesManager.defaultSaveDirURL)
        try? StubPlay.default.start(with: StubConfig(
                                        globalConfig: "StubFiles/.config",
                                        folders: ["StubFiles"],
                                        clearSaveDir: true,
                                        bundle: Bundle(for: type(of: self)),
                                        isEnabledServer: false,
                                        isLogging: false))
    }
    
    func testConfig() throws {
        let expectedRule = StubRewriteRules(
            rewriteRule:
                [
                    RewriteRule(method: nil, host: nil, path: "/a.txt", params: nil, body: nil),
                    RewriteRule(method: nil, host: "abc.com.au", path: "/b.txt", params: nil, body: nil),
                    RewriteRule(method: nil, host: "google\\..*", path: "/", params: nil, body: nil),
                    RewriteRule(headers: ["X-ABC-DEF" : "777"])
                ]
        )
        
        XCTAssertEqual(StubManager.shared.stubRules, expectedRule)
    }
    
    func testPostRegex() throws {
        let exp = expectation(description: "Success")
        
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: URL(string: "https://google.com/")!)
        request.httpMethod = "POST"
        request.httpBody = "yahooo".data(using: .utf8)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                fatalError("\(error)")
            }
            
            let str = String(data: data!, encoding: .utf8)
            XCTAssertEqual("gotcha\n", str)
            
            exp.fulfill()
        }
        task.resume()
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testHeader() throws {
        let exp = expectation(description: "Success")
        
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: URL(string: "https://header.com/hee")!)
        request.httpMethod = "POST"
        request.httpBody = "yahooo".data(using: .utf8)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                fatalError("\(error)")
            }
            
            let str = String(data: data!, encoding: .utf8)
            XCTAssertEqual("hello header\n", str)
            
            exp.fulfill()
        }
        task.resume()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
