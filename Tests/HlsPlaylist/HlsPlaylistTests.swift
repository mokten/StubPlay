//
//  HlsPlaylistTests.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 9/7/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation
import XCTest
@testable import StubPlay
 
class HlsPlaylistTests: XCTestCase {
    var playlist = HlsPlaylist()

    override func setUpWithError() throws {
        playlist = HlsPlaylist()
    }
 
    func testSimple() throws {
        let text = "HlsPlaylist/simple.m3u8".contents
        let result =  playlist.replace(text: text, with: AssetResource.redirectScheme, to: URL(string: "https://abc.com/def?g=h")!)!
        XCTAssertTrue(result.contains("https://abc.com/1234.aac"))
    }
    
    func testSimpleStubURL() throws {
        let text = "HlsPlaylist/simple.m3u8".contents
        let result =  playlist.replace(text: text, with: AssetResource.redirectScheme, to: URL(string: "https://abc.com/def?g=h")!, stubURL: URL(string: "http://127.0.01:9000/stub"))!
        XCTAssertTrue(result.contains("http://127.0.01:9000/stub?url=https://abc.com/1234.aac"))
    }

}
