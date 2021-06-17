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
        manager.stubSaver = StubFileSaver(filesManager: FilesManagableStub())
    }
    
    func testSave() throws {
      let r = StubRewriteRules(
            addToSavedStubRules: [
                RewriteRule(method: nil, host: nil, path: "/d/e", params: nil, body: nil)
            ],
            doNotSaveStubRules: [
                RewriteRule(method: nil, host: nil, path: "/d/e", params: nil, body: nil)
            ])
        
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(r)
        
        print(String(data: data, encoding: .utf8))
        
        
        let url = URL(string: "https://a.co/d/e?f=g")
        let stub = Stub(request: Request(method: .get, url: url, headers: nil, body: nil), response: nil)
        
        for i in 0..<10 {
            let exp = expectation(description: "Success")
            manager.save(stub, bodyData: nil) { result in
                switch result {
                case .success(let resultStub):
                    XCTAssertEqual(resultStub, Stub(index: i,
                                                    request: Request(method: .get, url: url, headers: nil, body: nil),
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
    
    func testSaveStubRules() throws {
        let url = URL(string: "https://a.co/d/e?f=g")
        let rule1 = RewriteRule(method: nil, host: "a.co", path: nil, params: nil, body: nil)
        manager.stubRules = StubRewriteRules(
            addToSavedStubRules: [
                rule1,
                RewriteRule(method: nil, host: nil, path: "/d/e", params: nil, body: nil),
                RewriteRule(method: nil, host: nil, path: nil, params: "f=g", body: nil)
            ],
            doNotSaveStubRules: nil)
        
        let stub = Stub(request: Request(method: .get, url: url, headers: nil, body: nil), response: nil)
        let exp = expectation(description: "Success")
        manager.save(stub, bodyData: nil) { result in
            switch result {
            case .success(let resultStub):
                XCTAssertEqual(resultStub, Stub(
                    rewriteRule: rule1,
                    index: 0,
                    request: Request(method: .get, url: url, headers: nil, body: nil),
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
        let url = URL(string: "https://a.co/d/e?f=g")
        let rule = RewriteRule(method: .get, host: ".*.co", path: nil, params: nil, body: nil)
        manager.stubRules = StubRewriteRules(
            addToSavedStubRules: [
                RewriteRule(method: nil, host: "a.co", path: nil, params: nil, body: nil),
            ],
            doNotSaveStubRules: nil)
        
        let stub = Stub(rewriteRule: rule, request: Request(method: .get, url: url, headers: nil, body: nil), response: nil)
        let exp = expectation(description: "Success")
        manager.save(stub, bodyData: nil) { result in
            switch result {
            case .success(let resultStub):
                XCTAssertEqual(resultStub, Stub(
                    rewriteRule: rule,
                    index: 0,
                    request: Request(method: .get, url: url, headers: nil, body: nil),
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

    func testDoNotSaveStubRules() throws {
        let url = URL(string: "https://a.co/d/e?f=g")
        let rule1 = RewriteRule(method: nil, host: "a.co", path: nil, params: nil, body: nil)
        manager.stubRules = StubRewriteRules(
            addToSavedStubRules: [
                rule1,
            ],
            doNotSaveStubRules: [
                rule1,
            ])
        
        let stub = Stub(request: Request(method: .get, url: url, headers: nil, body: nil), response: nil)
        let exp = expectation(description: "Success")
        manager.save(stub, bodyData: nil) { result in
            switch result {
            case .success(let resultStub):
                XCTAssertNil(resultStub)
                exp.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}
