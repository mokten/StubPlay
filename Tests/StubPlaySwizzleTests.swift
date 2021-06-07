//
//  StubPlaySwizzleTests.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 15/5/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import XCTest
@testable import StubPlay

class StubPlaySwizzleTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        try StubPlay.default.start(with: StubConfig(folders: ["Stub/2021-05-10"],
                                                        clearSaveDir: false,
                                                        isEnabledServer: false,
                                                        isLogging: true))
    }
    
    func testProtocolClassess() throws {
        try _test(URLSession.shared)
        try _test(URLSession(configuration: .default))
        try _test(URLSession(configuration: .ephemeral))
        try _test(URLSession(configuration: .background(withIdentifier: "test")))
    }
    
    func _test(_ session: URLSession) throws {
        XCTAssertTrue(StubURLProtocol.self == session.configuration.protocolClasses?.first!,
                      "Where is it? \(session.configuration.protocolClasses!)")
        
        XCTAssertEqual(.reloadIgnoringLocalCacheData, session.configuration.requestCachePolicy)
        XCTAssertNil(session.configuration.urlCache)
    } 
    
}
