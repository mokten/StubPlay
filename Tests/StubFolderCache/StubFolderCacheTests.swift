//
//
//  MessageFolderCacheTests.swift
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

class StubFolderCacheTests: XCTestCase {
    private var filesManager: FilesManager!
    private var folder: StubFolderCache!
    
    override func setUp() {
        super.setUp()
        filesManager = FilesManager(bundle: Bundle(for: type(of: self)))
        folder = StubFolderCache(baseFolder: "StubFolderCacheFiles/testMatch", filesManager: filesManager)
    }
    
    func testNoGet() throws {
        let request = Request(method: .get, url: URL(string: "https://httpbin.org/get"), headers: nil, body: nil)
        let noRequest = Request(method: .get, url: URL(string: "https://nothere.org/geta"), headers: nil, body: nil)
        let folderStubs = [Stub(rewriteRule: nil, index: 0, request: request, response: nil)]
        try folder.set(stubs: folderStubs.shuffled())
        let returnedStub = self.folder.get(request: noRequest)
        XCTAssertNil(returnedStub)
    }
    
    func testSet() throws {
        measure {
            do { try _testSet() } catch { XCTFail() }
        }
    }
    
    func testMatch()  throws {
        measure {
            do { try _testMatch() } catch { XCTFail() }
        }
    }
    
    func _testSet() throws {
        let request = Request(method: .get, url: URL(string: "https://httpbin.org/get"), headers: nil, body: nil)
        let folderStubs = (0...10000).map { Stub(rewriteRule: nil, index: $0, request: request, response: nil) }
        try folder.set(stubs: folderStubs.shuffled())
        let returnedMessages = folder.requestStubs[request.rewriteRule]!
        XCTAssertEqual(returnedMessages, folderStubs)
    }
    
    func _testMatch() throws {
        let expect = expectation(description: "")
        let queue = DispatchQueue(label: "com.mokten.messagefoldercache.tests.1")
        let queue2 = DispatchQueue(label: "com.mokten.messagefoldercache.tests.2", qos: .utility)
        let saveQueue = DispatchQueue(label: "com.mokten.saveQueue")
        let dispatchGroup = DispatchGroup()
        
        let request = Request(method: .get, url: URL(string: "https://httpbin.org/get"), headers: nil, body: nil)
        let messageCount = 1000
        let extraExpectedCount = 10
        
        let folderStubs: [Stub] = (0...messageCount).map { Stub(rewriteRule: nil, index: $0, request: request, response: nil) }
        
        let maxIndex = messageCount
        var expectedMessages: [Stub] = folderStubs
        for _ in messageCount...(messageCount + extraExpectedCount) {
            expectedMessages.append(Stub(rewriteRule: nil, index: maxIndex, request: request, response: nil))
        }
        
        try folder.set(stubs: folderStubs.shuffled())
        
        var returnedMessages: [Stub] = []
        for _ in 0...(expectedMessages.count/2 - 1)  {
            dispatchGroup.enter()
            queue.async {
                defer { dispatchGroup.leave() }
                guard let m = self.folder.get(request: request) else { return }
                saveQueue.async { returnedMessages.append(m) }
            }
            
            dispatchGroup.enter()
            queue2.async {
                defer { dispatchGroup.leave() }
                guard let m = self.folder.get(request: request) else { return }
                saveQueue.async { returnedMessages.append(m) }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            saveQueue.async {
                XCTAssertEqual(returnedMessages, expectedMessages)
                expect.fulfill()
            }
        }))
        
        waitForExpectations(timeout: 2)
    }
}
