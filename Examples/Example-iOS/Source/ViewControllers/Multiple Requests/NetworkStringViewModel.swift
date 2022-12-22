//
//  NetworkStringViewModel.swift
//  Example-iOS
//
//  Created by Yoo-Jin Lee on 12/7/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

class NetworkStringViewModel {
    private lazy var session = URLSession(configuration: .default)
    let url: URL
    let count: Int
    
    init(url: URL, count: Int = 5) {
        self.url = url
        self.count = count
    }
    
    func fetch(completion: @escaping ([String]) -> Void) {
        var texts: [String] = []
        
        (0..<count).forEach { _ in
            var request = URLRequest(url: url)
            if #available(iOS 14.5, *) {
                request.assumesHTTP3Capable = true
            }
            session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    fatalError("\(error)")
                }
                
                guard let data = data, let txt = String(data: data, encoding: .utf8) else {
                    return completion([])
                }
                
                texts.append(txt.trimmingCharacters(in: .whitespacesAndNewlines))
                
                if texts.count == self.count {
                    completion(texts)
                }
                
            }.resume()
        }
    }
}
