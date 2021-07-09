//
//  StubFolderCacheLoopTests.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 26/6/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import XCTest
@testable import StubPlay

class StubFolderCacheLoopTests: XCTestCase {
    private var filesManager: FilesManager!
    
    override func setUp() {
        super.setUp()
        filesManager = FilesManager(bundle: Bundle(for: type(of: self)))
    }
     
    func testNotLoop() throws {
        guard let folder = StubFolderCache(baseFolder: "StubFolderCacheFiles/testLoad", filesManager: filesManager) else {
            return XCTAssertTrue(false)
        }
        folder.load()
        let request = Request(method: .get, url: URL(string: "https://a.org/a")!)
        XCTAssertEqual(Array((0...9)) + [9,9,9,9,9], (0...14).map { _ in folder.get(request: request)?.index })
    }
    
    func testLoop() throws {
        guard let folder = StubFolderCache(baseFolder: "StubFolderCacheFiles/testLoop", filesManager: filesManager) else {
            return XCTAssertTrue(false)
        }
        folder.load()
        let request = Request(method: .get, url: URL(string: "https://a.org/a")!)
        XCTAssertEqual(Array((0...9)) + Array((0...4)), (0...14).map { _ in folder.get(request: request)?.index })
    }
    
    func testLoopToIndex5() throws {
        guard let folder = StubFolderCache(baseFolder: "StubFolderCacheFiles/testLoop", filesManager: filesManager) else {
            return XCTAssertTrue(false)
        }
        folder.load()
        let request = Request(method: .get, url: URL(string: "https://b.org/b")!)
        XCTAssertEqual(Array((0...12)) + [5,6], (0...14).map { _ in folder.get(request: request)?.index })
    }

}
