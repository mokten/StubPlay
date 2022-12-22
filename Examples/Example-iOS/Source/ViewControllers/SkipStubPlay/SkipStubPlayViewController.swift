//
//  SkipStubPlayViewController.swift
//  Example-iOS
//
//  Created by Yoo-Jin Lee on 17/6/2022.
//  Copyright © 2022 Mokten Pty Ltd. All rights reserved.
//

import Foundation
import UIKit

class SkipStubPlayViewController: NiblessViewController {
    
    private let textView = UITextView()
    private let viewModel = NetworkStringViewModel(url: URL(string: "https://google.com")!, count: 1)
    
    override init() {
        super.init()
        self.title = "Skip StubPlay"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(textView)
        
        self.textView.text = "\(title ?? "")\n"
        textView.accessibilityIdentifier = "stubText"
        
        print("viewDidLoad=")
        
        viewModel.fetch { texts in
            print("viewDidLoad2=")
            DispatchQueue.main.async {
                for (i, text) in texts.enumerated() {
                    self.textView.text += "\(i): \(text)\n"
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        textView.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 300)
    }
    
}
