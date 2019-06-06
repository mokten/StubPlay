//
//
//  AlamofireViewController.swift
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
import StubPlay_iOS
import Alamofire

class AlamofireViewController: NiblessViewController {
    
    private var textView = UITextView()
    
    private var sessionManager: SessionManager?
    
    override init() {
        super.init()
        self.title = "Alamofire"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(textView)
        testAlamofireRequest()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        textView.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 300)
    }
    
    func testAlamofireRequest() {
        let url = URL(string: "https://raw.githubusercontent.com/Alamofire/Alamofire/0ac38d7e312e87aeea608d384e44401f3d8a6b3d/Tests/Resources/Responses/JSON/valid_data.json")!
        
        //        let url = URL(string: "https://a.ab.com/data")!
        //        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
        //        let url = URL(string: "https://a.ab/test.txt")!
        
        let configuration = URLSessionConfiguration.default
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        // Must keep reference
        self.sessionManager = sessionManager
        
        let urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        
        Alamofire.request(urlRequest).responseData(completionHandler: { response in
            
            if let error = response.error {
                fatalError("\(error)")
            }
            
            guard let data = response.data,
                let str = String(data: data, encoding: .utf8) else {
                    fatalError("No data")
            }
            
            DispatchQueue.main.async {
                self.textView.text = str
            }
            
        })
    }
}

