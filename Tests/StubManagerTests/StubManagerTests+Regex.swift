//
//  StubManagerTests+Regex.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 23/6/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import XCTest
@testable import StubPlay

extension StubManagerTests {
    
    func testRegexSave() throws {
        let rule = RewriteRule(method: .get, host: "a\\.b\\.c.*", path: "/d/e", params: "f=g", body: nil)
        let rules = StubRewriteRules(
            rewriteRule: [
                rule
            ])
        
        let url = URL(string: "https://a.b.co:443/d/e?f=g")!
        let stub = Stub(request: Request(method: .get, url: url), response: nil)
        
        manager.stubRules = rules
        for i in 0..<100 {
            let exp = expectation(description: "Success")
            manager.save(stub, bodyData: nil) { result in
                switch result {
                case .success(let resultStub):
                    XCTAssertEqual(resultStub, Stub(rewriteRule: rule,
                                                    index: i,
                                                    request: Request(method: .get, url: url),
                                                    response: nil)
                    )
                    exp.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testRegexNotSave() throws {
        let rule = RewriteRule(method: .post, host: "a\\.b\\.c.*", path: "/d/e", params: "f=g", body: nil)
        let rules = StubRewriteRules(
            rewriteRule: [
                rule
            ])
        
        let url = URL(string: "https://a.b.co:443/d/e?f=g")!
        let stub = Stub(request: Request(method: .get, url: url), response: nil)
        
        manager.stubRules = rules
        for i in 0..<100 {
            let exp = expectation(description: "Success")
            manager.save(stub, bodyData: nil) { result in
                switch result {
                case .success(let resultStub):
                    XCTAssertEqual(resultStub, Stub(rewriteRule: nil,
                                                    index: i,
                                                    request: Request(method: .get, url: url),
                                                    response: nil)
                    )
                    exp.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}
