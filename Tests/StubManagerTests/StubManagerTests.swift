//
//  StubManagerTests.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 17/6/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import XCTest
@testable import StubPlay

class StubManagerTests: XCTestCase {
    let manager = StubManager.shared
    
    override func setUp() {
        
        try? StubPlay.default.start(with: StubConfig(
                                        folders: ["StubFiles"],
                                        clearSaveDir: true,
                                        bundle: Bundle(for: type(of: self)),
                                        isEnabledServer: false,
                                        isLogging: false))
        manager.stubSaver = StubFileSaver(filesManager: FilesManagableStub())
    }
    
    func testSaveStubRules() throws {
        let exp = expectation(description: "Success")
        
        let rule1 = RewriteRule(method: nil, host: "a.co", path: nil, params: nil, body: nil)
        manager.stubRules = StubRewriteRules(
            rewriteRule: [
                rule1,
                RewriteRule(method: nil, host: nil, path: "/d/e", params: nil, body: nil),
                RewriteRule(method: nil, host: nil, path: nil, params: "f=g", body: nil),
                RewriteRule(method: nil, host: "a\\..*", path: "/d/e", params: "f=g", body: nil),
            ])
        
        let url = URL(string: "https://a.co/d/e?f=g")!
        let stub = Stub(request: Request(method: .get, url: url), response: nil)
        manager.save(stub, bodyData: nil) { result in
            switch result {
            case .success(let resultStub):
                XCTAssertEqual(resultStub, Stub(
                                rewriteRule: rule1,
                                index: 0,
                                request: Request(method: .get, url: url),
                                response: nil)
                )
                exp.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSaveStubRulesOrdered() throws {
        let exp = expectation(description: "Success")
        
        let rule1 = RewriteRule(method: nil, host: "a\\..*", path: "/d/e", params: "f=g", body: nil)
        manager.stubRules = StubRewriteRules(
            rewriteRule: [
                rule1,
                RewriteRule(method: nil, host: nil, path: "/d/e", params: nil, body: nil),
                RewriteRule(method: nil, host: nil, path: nil, params: "f=g", body: nil),
                RewriteRule(method: nil, host: "a.co", path: nil, params: nil, body: nil)
            ])
        
        let url = URL(string: "https://a.co/d/e?f=g")!
        let stub = Stub(request: Request(method: .get, url: url), response: nil)
        manager.save(stub, bodyData: nil) { result in
            switch result {
            case .success(let resultStub):
                XCTAssertEqual(resultStub, Stub(
                                rewriteRule: rule1,
                                index: 0,
                                request: Request(method: .get, url: url),
                                response: nil)
                )
                exp.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSaveStubRulesWithStubHasRule() throws {
        let url = URL(string: "https://a.co/d/e?f=g")!
        let rule = RewriteRule(method: .get, host: ".*\\.co", path: nil, params: nil, body: nil)
        
        manager.stubRules = StubRewriteRules(
            rewriteRule: [
                rule
            ])
        
        let stub = Stub(rewriteRule: nil, request: Request(method: .get, url: url), response: nil)
        let exp = expectation(description: "Success")
        manager.save(stub, bodyData: nil) { result in
            switch result {
            case .success(let resultStub):
                XCTAssertEqual(resultStub, Stub(
                                rewriteRule: rule,
                                index: 0,
                                request: Request(method: .get, url: url),
                                response: nil)
                )
                exp.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}
