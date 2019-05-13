//
//  Copyright (c) 2019 Mokten Pty Ltd
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

public protocol StubSaver {
    func save(_ stub: Stub, bodyData: Data?)
}

public protocol StubCache {
    func load() throws
    func get(request: Request) -> Stub?
}

public class StubManager {
    public static let shared = StubManager()

    public var stubSaver: StubSaver?
    
    private let cacheQueue = DispatchQueue(label: "com.mokten.stubmanager.stubs", qos: .utility, attributes: .concurrent)
    
    private var _stubCaches: [StubCache] = []
    private var stubCaches: [StubCache] {
        get {
            var stubCaches: [StubCache] = []
            cacheQueue.sync {
                stubCaches = self._stubCaches
            }
            return stubCaches
        }
        
        set {
            cacheQueue.async(flags: .barrier) {
                self._stubCaches = newValue
            }
        }
    }
    
    private init() { }
    
    func get(request: Request) -> Stub? {
        for cache in stubCaches {
            if let cacheStub = cache.get(request: request) {
                return cacheStub
            }
        }
        return nil
    }
    
    // increments index
    func save(_ stub: Stub, bodyData: Data?) {
        stubSaver?.save(stub, bodyData: bodyData)
    }
    
    func add(_ cache: StubCache) {
        stubCaches.append(cache)
    }
}
