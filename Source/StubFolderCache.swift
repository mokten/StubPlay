//
//
//  StubFolderCache.swift
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

public typealias Folder = String

public final class StubFolderCache {
    
    private let baseFolder: Folder
    private var filesManager: FilesManager
    private let matchQueue = DispatchQueue(label: "com.mokten.stubfoldercache.match", qos: .background)
    private let requestStubsQueue = DispatchQueue(label: "com.mokten.stubfoldercache.stubs", qos: .background, attributes: .concurrent)
    
    private var _requestStubs: [RewriteRule: [Stub]] = [:]
    private(set) var requestStubs: [RewriteRule: [Stub]] {
        get {
            var requestStubs: [RewriteRule: [Stub]] = [:]
            requestStubsQueue.sync {
                requestStubs = self._requestStubs
            }
            return requestStubs
        }
        
        set {
            requestStubsQueue.async(flags: .barrier) {
                self._requestStubs = newValue
            }
        }
    }
    
    public init?(baseFolder: Folder, filesManager: FilesManager) {
        self.baseFolder = baseFolder
        self.filesManager = filesManager
    }
    
    public func set(stubs: [Stub]) throws {
        var requestStubs: [RewriteRule: [Stub]] = [:]
        
        // Organize stubs with their Request key
        stubs.forEach({ stub in
            requestStubs[stub.rewriteRule ?? stub.request.rewriteRule, default: []].append(stub)
        })
        
        // Sort stubs
        for key in requestStubs.keys {
            let stubs = requestStubs[key]
            requestStubs[key] = stubs?.sorted{ $0.index < $1.index }
        }
        
        self.requestStubs = requestStubs
    }
}

extension StubFolderCache: StubCache {
    
    public func load() throws {
        try matchQueue.sync {
            var stubs: [Stub] = []
            let urls = filesManager.urls(at: baseFolder)?.filter { $0.pathExtension == "json" && !$0.lastPathComponent.contains(".body.")}
            try urls?.forEach({ url in
                let stub: Stub = try filesManager.get(Stub.self, from: url)
                stubs.append(stub)
            })
            try set(stubs: stubs)
        }
    }
    
    public func get(request: Request) -> Stub? {
        var stub: Stub?
        
        matchQueue.sync {
            guard let matchedRewriteRule = self.requestStubs.keys.first(where: { $0.matches(request) }),
                var matchedStubs = self.requestStubs[matchedRewriteRule],
                var matchedStub = matchedStubs.first else {
                    return
            }
            
            defer {
                stub = matchedStub
                self.requestStubs[matchedRewriteRule] = matchedStubs
            }
            
            if matchedStub.responseData == nil,
                let responseDataFileName = matchedStub.responseDataFileName,
                let bodyData = try? filesManager.bundleData(for: responseDataFileName, inDirectory: baseFolder) {
                matchedStub.responseData = bodyData
            }
            
            if matchedStubs.count > 1 {
                matchedStubs.removeFirst()
            } else {
                matchedStubs[0] = matchedStub
            }
        }
        
        return stub
    }
}
