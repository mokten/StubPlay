//
//
//  FilesManagerTests.swift
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

class FilesManagerTests: XCTestCase {
    
    var filesManager: FilesManager!
    
    lazy var defaultMessage: Stub = {
        let bodyUrl = "https://httpbin.org/get"
        let rule = RewriteRule(method: .post, host: "httpbin.org", path: "hi", params: nil)
        let response = Response(statusCode: 200, mimeType: "application/json", headers: ["hi" : "ho"], bodyUrl: bodyUrl)
        let request = Request(method: .get, url: URL(string: "https://httpbin.org/get")!)
        return Stub(rewriteRule: rule, index: 0, request: request, response: response)
    }()
    
    override func setUp() {
        super.setUp()
        filesManager = FilesManager(bundle: Bundle(for: type(of: self)))
    }
    
    func testReadFilesInDirectory() {
        let expectedFiles = ["__a=b.get.0.json","_.get.0.json","_a.get.0.json","a.post.0.json"]
        let dirURL = (filesManager?.bundleUrl(for: "FilesManagerFiles/testReadFilesInDirectory"))!
        let files = (try! filesManager?.urls(at: dirURL))!
        
        XCTAssertEqual(files.count, expectedFiles.count)
        
        let fileNames = files.map { $0.lastPathComponent }
        for file in fileNames {
            XCTAssertTrue(expectedFiles.contains(file))
        }
    }
    
    func testSaveReadMultipleTimes() throws {
        let filename = "testSave.json"
        
        try [#"{"hi":"0"}"#,
         #"{"hi":"1"}"#,
         #"{"hi":"2"}"#].forEach { text in
            
            let saveFileURL = try filesManager.save(data: text.data(using: .utf8), to: filename)!
            guard let returnedData = try filesManager.data(from: saveFileURL) else {
                return XCTAssertTrue(false, "Bad \(filename) for \(text)")
            }
            let returnedText = String(data: returnedData, encoding: .utf8)
            XCTAssertEqual(returnedText, text)
        }
    }
    
    func testSaveMessage() throws {
        let filename = "testSave.json"
        let stub = defaultMessage
        filesManager?.save(stub, to: filename)
        
        // TODO:
//        let returnedMessage = try filesManager.get(Stub.self, from: url)
//        XCTAssertEqual(returnedMessage, stub)
    }
    
    func testGetDecodable() throws {
        let filename = "FilesManagerFiles/testGetDecodable/file.json"
        let stub = defaultMessage
        let url = filesManager.bundleUrl(for: filename)!
        let returnedMessage = try filesManager.get(Stub.self, from: url)
        XCTAssertEqual(returnedMessage, stub)
    }
}

