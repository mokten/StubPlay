//
//
//  ViewController.swift
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

import UIKit
import StubPlay_iOS

class MultipleViewController: NiblessViewController {
    private let textView = UITextView()
    
    override init() {
        super.init()
        self.title = "Multiple Requests"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(textView)
        
        (0...4).forEach { index in
            testJsonRequest(index)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        textView.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 300)
    }

    func testJsonRequest(_ index: Int) {
        let url = URL(string: "https://a.ab/multiple.txt")

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: url!) { [weak self] data, response, error in
            guard let self = self else { return }

            guard error == nil else {
                print("ViewController", error!)
                return
            }

            guard let data = data, let txt = String(data: data, encoding: .utf8) else {
                print("ViewController no data")
                return
            }

            DispatchQueue.main.async {
                self.textView.text += "This is request: \(index)\n\(txt)\n------\n"
            }
        }

        task.resume()
    }

}

