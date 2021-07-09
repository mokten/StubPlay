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

/*
 Manages the mapping of the request to the Stub
 */
public class StubManager {
    public static let shared = StubManager()
    
    public var stubSaver: StubSaver?
    
    @Atomic
    private var stubCaches: [StubCache] = []
    
    public var stubRules: StubRewriteRules? {
        didSet {
            guard let stubRules = stubRules else {
                saveRewriteRules = [:]
                return
            }
            stubRules.rewriteRule?.forEach{ rule in
                saveRewriteRules[rule] = 0
            }
        }
    }
    
    /// Used to set a rewrite rule in the saved stub
    /// - Only sets when matched and the stub does not already have a rewrite rule
    /// - When matched increases the position by 1
    @Atomic
    private var saveRewriteRules: [RewriteRule: Int] = [:]
    
    private init() { }
    
    func get(request: Request, isChangeIndex: Bool = true) -> Stub? {
        for cache in stubCaches {
            if let cacheStub = cache.get(request: request, isChangeIndex: isChangeIndex) {
                return cacheStub
            }
        }
        return nil
    }
    
    // increments index
    func save(_ stub: Stub, bodyData: Data?, completion: ((Result<Stub?, Error>) -> Void)? = nil) {
        
        _saveRewriteRules.mutate { [weak self] saveRewriteRules in
            guard let self = self else { return }
            
            var stub = stub
            
            if let stubRules = self.stubRules {                
                if let matchedRewriteRule = stubRules.rewriteRule?.first(where: { $0.matches(stub.request) }),
                   let index = saveRewriteRules[matchedRewriteRule] {
                    stub.rewriteRule = matchedRewriteRule
                    stub.index = index
                    saveRewriteRules[matchedRewriteRule] = index + 1
                }
            }
            
            self.stubSaver?.save(stub, bodyData: bodyData, completion: completion)
        }
    }
    
    func add(_ cache: StubCache) {
        _stubCaches.mutate { stubCaches in
            stubCaches.append(cache)
        }
    }
    
    func reset() {
        _stubCaches.mutate { stubCaches in
            stubCaches.removeAll()
            stubSaver = nil
            stubRules = nil
        }
    }
}
