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

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        testImageRequest()
        testJsonRequest()
    }

    func testImageRequest() {
        let url = URL(string: "https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: url!) { [weak self] data, response, error in
            guard let self = self else { return }

            guard error == nil else {
                print("ViewController", error!)
                return
            }

            guard let data = data else {
                print("ViewController no data")
                return
            }

            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }

        task.resume()
    }

    func testJsonRequest() {
        let url = URL(string: "https://a.ab/test.txt")

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: url!) { [weak self] data, response, error in

            guard error == nil else {
                print("ViewController", error!)
                return
            }

            guard let data = data else {
                print("ViewController no data")
                return
            }

            DispatchQueue.main.async {
                self?.textView.text = String(data: data, encoding: .utf8)
            }
        }

        task.resume()
    }

}

