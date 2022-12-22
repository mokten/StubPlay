//
//  MultipleViewTests.swift
//  Example-iOSTests
//
//  Created by Yoo-Jin Lee on 12/7/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import XCTest
import StubPlay
@testable import Example_iOS

class NetworkStringViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        let config = StubConfig(
            folders: ["MultipleTests"],
            saveResponsesDirURL: nil,
            skipSavingStubbedResponses: false,
            validateResponseFile: false,
            clearSaveDir: true,
            bundle: Bundle.test,
            isEnabledServer: true,
            protocolURLSessionConfiguration: nil,
            isLogging: true)
        try StubPlay.default.start(with: config)
    }
    
    func testPerformanceExample() throws {
        let expec = expectation(description: "Success")
        let viewModel = NetworkStringViewModel(url: URL(string: "https://a.ab/multiple.txt")!, count: 5)
         
        viewModel.fetch { texts in
            XCTAssertEqual(texts, ["unittest.local.0",
                                   "unittest.local.1",
                                   "unittest.local.2",
                                   "unittest.local.2",
                                   "unittest.local.2"])
            expec.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error { XCTFail(error.localizedDescription)}
        }
    }
    
}
