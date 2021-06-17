- [Unit Test](#unit-test)

# Unit Test

## Introduction

Complete example in Example-iOS.xcodeproj

./ExampleTests.swift
```swift
import XCTest
import StubPlay
@testable import Example_iOS

class ExampleTests: XCTestCase {

    override func setUp() {
      // Loads all stub files in the directory Test1
      let config = StubConfig(folders: ["Test1"],
                              saveResponsesDirURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("stubplay"),
                              skipSavingStubbedResponses: false,
                              validateResponseFile: false,
                              clearSaveDir: true,
                              bundle: Bundle(for: type(of: self) ,
                              isEnabledServer: true,
                              protocolURLSessionConfiguration: nil,
                              isLogging: true)
      try StubPlay.default.start(with: config)
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
```

./Test1/multiple.get.0.json
```json
{
  "bodyFileName" : "multiple.get.0.body.txt",
  "response" : {
    "headers" : {
    },
    "statusCode" : 200,
    "mimeType" : "text\/plain",
    "Cache-Control" : "max-age=89098789",
  },
  "request" : {
    "url" : "https:\/\/a.ab\/multiple.txt",
    "method" : "get",
    "headers" : {
      "Accept-Language" : "en;q=1.0",
      "User-Agent" : "Example-iOS\/0.1 (com.mokten.Example-iOS; build:1; iOS 12.1.0) Alamofire\/4.8.2",
      "Accept-Encoding" : "gzip;q=1.0, compress;q=0.5"
    }
  },
  "index" : 0
}
```

 