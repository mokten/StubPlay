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

public protocol StubCache {
    func load() throws
    
    /// Returns Stub if found
    /// - Parameters:
    ///   - request: request to match a Stub
    ///   - isChangeIndex: true changs the index, otherwise does not change the index
    func get(request: Request, isChangeIndex: Bool) -> Stub?
}

public typealias Folder = String

public final class StubFolderCache {
    
    private let baseFolder: Folder
    private var filesManager: FilesManager
    private let matchQueue = DispatchQueue(label: "com.mokten.stubfoldercache.match")
    
    private let forceSkipSave: Bool?
    private let validateResponseFile: Bool
    public var invalideURLs: [URL] = []
    
    private(set) var requestStubs: [RewriteRule: [Stub]] = [:]
    private(set) var requestStubsIndex: [RewriteRule: Int] = [:]
    
    public init?(baseFolder: Folder,
                 filesManager: FilesManager,
                 forceSkipSave: Bool? = nil,
                 validateResponseFile: Bool = false) {
        self.baseFolder = baseFolder
        self.filesManager = filesManager
        self.forceSkipSave = forceSkipSave
        self.validateResponseFile = validateResponseFile
    }
    
    public func set(stubs: [Stub]) {
        matchQueue.async { [weak self] in
            do {
                try self?._set(stubs: stubs)
            } catch {
                logger(error: error)
            }
        }
    }
    
    
    func _set(stubs: [Stub]) throws {
        var requestStubs: [RewriteRule: [Stub]] = [:]
        var requestStubsIndex: [RewriteRule: Int] = [:]
        
        // Organize stubs with their Request key
        stubs.forEach { stub in
            requestStubs[stub.rewriteRule ?? stub.request.rewriteRule, default: []].append(stub)
        }
        
        // Sort stubs
        for key in requestStubs.keys {
            guard let stubs = requestStubs[key] else { continue }
            requestStubs[key] = stubs.sorted{ $0.index < $1.index }
            requestStubsIndex[key] = 0
        }
        self.requestStubs = requestStubs
        self.requestStubsIndex = requestStubsIndex
    }
}

extension StubFolderCache: StubCache {
    
    public func load() {
        matchQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                var stubs: [Stub] = []
                let urls = try self.filesManager.urls(at: self.baseFolder)?.filter { $0.pathExtension == "json" && !$0.lastPathComponent.contains(".body.")}
                var invalideURLs: [URL] = []
                try urls?.forEach { url in
                    var stub: Stub = try self.filesManager.get(Stub.self, from: url)
                    
                    if self.validateResponseFile, let isValid = try? self.hasValidResponseFile(for: stub), !isValid {
                        invalideURLs.append(url)
                        return
                    }
                    
                    if let forceSkipSave = self.forceSkipSave {
                        stub.skipSave = forceSkipSave
                    }
                    stubs.append(stub)
                }
                try self._set(stubs: stubs)
                self.invalideURLs = invalideURLs
            } catch {
                logger(error: error)
            }
        }
    }
    
    public func get(request: Request, isChangeIndex: Bool = true) -> Stub? {
        var stub: Stub?
        
        matchQueue.sync { [weak self] in
            guard let self = self else { return }
            
            guard let matchedRewriteRule = self.requestStubs.keys.first(where: { $0.matches(request) }),
                  let matchedStubs = self.requestStubs[matchedRewriteRule],
                  var index = self.requestStubsIndex[matchedRewriteRule],
                  var matchedStub = matchedStubs[safe: index] else {
                return
            }
            
            if matchedStub.responseData == nil,
               let responseDataFileName = matchedStub.responseDataFileName,
               let bodyData = try? filesManager.bundleData(for: responseDataFileName, inDirectory: baseFolder) {
                matchedStub.responseData = bodyData
            }
            
            if isChangeIndex {
                let lastIndex = matchedStubs.count - 1
                if index >= lastIndex {
                    if let newIndex = matchedStub.whenAtEndLoopToIndex {
                        index = newIndex
                    }
                } else {
                    index += 1
                }
            }
            self.requestStubsIndex[matchedRewriteRule] = index
            stub = matchedStub
        }
        
        return stub
    }
    
    /// true if not responseDataFileName or response file exists
    public func hasValidResponseFile(for stub: Stub) throws -> Bool {
        guard let responseDataFileName = stub.responseDataFileName else {
            return true
        }
        return try filesManager.bundleResourceExists(for: responseDataFileName, inDirectory: baseFolder)
    }
    
    public func responsePath(for stub: Stub) -> String? {
        guard let responseDataFileName = stub.responseDataFileName else {
            return nil
        }
        return filesManager.bundlePath(for: responseDataFileName, inDirectory: baseFolder)
    }
}
