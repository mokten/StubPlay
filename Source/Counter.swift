//
//
//  FolderSaver.swift
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

public final class Counter<Key> where Key : Hashable {
    private let countQueue = DispatchQueue(label: "com.mokten.counter", qos: .utility)
    private let keysQueue = DispatchQueue(label: "com.mokten.counter", qos: .utility, attributes: .concurrent)
    
    private var _keys: [Key: Int] = [:]
    private(set) var keys: [Key: Int] {
        get {
            var keys: [Key: Int] = [:]
            keysQueue.sync {
                keys = self._keys
            }
            return keys
        }
        
        set {
            keysQueue.async(flags: .barrier) {
                self._keys = newValue
            }
        }
    }
}

extension Counter {
    public func count(for key: Key) -> Int {
        var requestCount : Int = 0
        countQueue.sync {
            let count = self.keys[key, default: -1] + 1
            self.keys[key] = count
            requestCount = count
        }
        return requestCount
    }
}
