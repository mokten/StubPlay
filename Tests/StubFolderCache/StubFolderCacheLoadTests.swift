//
//
//  MessageFolderCacheLoadTests.swift
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

#if os(iOS)
@testable import StubPlay_iOS
#else
@testable import StubPlay_tvOS
#endif

class StubFolderCacheLoadTests: XCTestCase {
    
    private var filesManager: FilesManager!
    
    override func setUp() {
        super.setUp()
        filesManager = FilesManager(bundle: Bundle(for: type(of: self)))
    }
    
    func testLoad()  throws {
        measure {
            do { try _testLoad() } catch { XCTAssertTrue(false) }
        }
    }
    
    func testLoadSimple()  throws {
        measure {
            do { try _testLoadSimple() } catch { XCTAssertTrue(false) }            
        }
    }
    
    func _testLoad() throws {
        guard let folder = StubFolderCache(baseFolder: "StubFolderCacheFiles/testLoad", filesManager: filesManager) else {
            return XCTAssertTrue(false)
        }
        
        try folder.load()
        
        let request = Request(method: .get, url: URL(string: "https://a.org/a"), headers: nil, body: nil)
        let returnedRequestMessages = folder.requestStubs
        let returnedMessages = returnedRequestMessages[request.rewriteRule]
        XCTAssertEqual(returnedMessages,  (0...9).map { Stub(rewriteRule: nil, index: $0, request: request, response: nil) })
    }
    
    func _testLoadSimple()  throws {
        let expectA = expectation(description: "")
        let expectB = expectation(description: "")
        
        guard let folder = StubFolderCache(baseFolder: "StubFolderCacheFiles/testLoadSimple", filesManager: filesManager) else {
            return XCTAssertTrue(false)
        }
        
        let queueA = DispatchQueue(label: "com.mokten.messagefoldercache.tests.1")
        let queueB = DispatchQueue(label: "com.mokten.messagefoldercache.tests.2", qos: .utility)
        let saveQueueA = DispatchQueue(label: "com.mokten.saveQueue.a")
        let saveQueueB = DispatchQueue(label: "com.mokten.saveQueue.b")
        let dispatchGroup = DispatchGroup()
        
        let requestA = Request(method: .get, url: URL(string: "https://a.org/a"), headers: nil, body: nil)
        let requestB = Request(method: .get, url: URL(string: "https://b.org/b"), headers: nil, body: nil)
        
        let expectedA = (0...4).map { _ in Stub(rewriteRule: nil, index: 0, request: requestA, response: nil) }
        
        let expectedB = [Stub(rewriteRule: nil, index: 0, request: requestB, response: nil),
                                    Stub(rewriteRule: nil, index: 1, request: requestB, response: nil),
                                    Stub(rewriteRule: nil, index: 1, request: requestB, response: nil),
                                    Stub(rewriteRule: nil, index: 1, request: requestB, response: nil),
                                    Stub(rewriteRule: nil, index: 1, request: requestB, response: nil)]
        
        try folder.load()
        
        var returnedMessagesA: [Stub] = []
        var returnedMessagesB: [Stub] = []
        
        for _ in 0...(expectedA.count - 1)  {
            dispatchGroup.enter()
            queueA.async {
                defer { dispatchGroup.leave() }
                guard let m = folder.get(request: requestA) else { return }
                saveQueueA.async { returnedMessagesA.append(m) }
            }
            
            dispatchGroup.enter()
            queueB.async {
                defer { dispatchGroup.leave() }
                guard let m = folder.get(request: requestB) else { return }
                saveQueueB.async { returnedMessagesB.append(m) }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            saveQueueA.async {
                XCTAssertEqual(returnedMessagesA, expectedA)
                expectA.fulfill()
            }
            
            saveQueueB.async {
                XCTAssertEqual(returnedMessagesB, expectedB)
                expectB.fulfill()
            }
        }))
        
        waitForExpectations(timeout: 1)
    }
}
