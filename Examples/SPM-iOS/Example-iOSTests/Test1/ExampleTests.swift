//
//  Example_iOSTests.swift
//  Example-iOSTests
//
//  Created by Yoo-Jin Lee on 8/3/20.
//  Copyright © 2020 Mokten Pty Ltd. All rights reserved.
//

import XCTest
import StubPlay
@testable import Example_iOS

class ExampleTests: XCTestCase {

    override func setUp() {
      // Loads all stub files in the directory Test1
        try! StubPlay.default.enableStub(for: StubConfig(folders: ["Test1"], bundle: Bundle(for: type(of: self))))
    }
    
    /*
    Requests the url: https://a.ab/multiple.txt
    */
    func testJsonRequest() {
        let expec = expectation(description: "Success")
        let url = URL(string: "https://a.ab/multiple.txt")
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: url!) { data, response, error in
            let data = data!
            let txt = String(data: data, encoding: .utf8)!
            XCTAssertEqual(txt, "This is a local file for Test1\n")
            expec.fulfill()
        }

        task.resume()
        wait(for: [expec], timeout: 1)
    }

}
