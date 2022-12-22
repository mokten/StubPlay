//
//  Example_iOSUITests.swift
//  Example-iOSUITests
//
//  Created by Yoo-Jin Lee on 12/7/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import XCTest
import StubPlay

class Example_iOSUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
         
            let config = StubConfig(
                folders: ["StubsUI"],
                saveResponsesDirURL: nil,
                skipSavingStubbedResponses: false,
                clearSaveDir: true,
                bundle: Bundle.uiTest,
                isEnabledServer: false,
                protocolURLSessionConfiguration: nil,
                isLogging: true)
            try StubPlay.default.start(with: config)

            let app = XCUIApplication()
            setupSnapshot(app)
            app.launch()
        
        print("Snapshot.screenshotsDirectory", Snapshot.screenshotsDirectory)
    }
    
    func testExample() throws {
        let expectedResult: String = """
0: This is local file 0
1: This is local file 1
2: This is local file 2
3: This is local file 2
4: This is local file 2

"""
        
        let app = XCUIApplication()
        let textView = app.textViews["stubText"]
        
        let predicate = NSPredicate(format: "exists == 1", argumentArray: nil)
        expectation(for: predicate, evaluatedWith: textView, handler: nil)
        
        XCTAssertEqual(textView.value as? String, expectedResult)
        snapshot("MultRequests")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func takeScreenshot(_ name: String) {
        let fullScreenshot = XCUIScreen.main.screenshot()
        let screenshot = XCTAttachment(uniformTypeIdentifier: "public.png", name: "Screenshot-\(name)-\(UIDevice.current.name).png", payload: fullScreenshot.pngRepresentation, userInfo: nil)
        screenshot.lifetime = .keepAlways
        
        add(screenshot)
    }
}
