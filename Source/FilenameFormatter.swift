//
//
//  FileNameHelper.swift
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

private enum Constants {
    static let maxExtensionLength = 10
    static let maxFilenamePartLength = 100
}

public protocol FilenameFormatter {
    func filename(for stub: Stub) -> String
}

public struct DefaultFilenameFormatter: FilenameFormatter {
    
    public init() { }
    
    public func filename(for stub: Stub) -> String {
        return "\(stub.name).\(stub.request.method.rawValue).\(stub.index).json"
    }
}

public struct BodyFilenameFormatter: FilenameFormatter {
    
    public init() { }
    
    public func filename(for stub: Stub) -> String {
        return "\(stub.name).\(stub.request.method.rawValue).\(stub.index).body.\(stub.fileExtension)"
    }
}

public protocol Canonical {
    func path(_ path: String) -> String
}

public extension Canonical {
    func path(_ path: String) -> String {
        guard path.count > 1 else { return "_" }
        
        let newPath = path.starts(with: "/") ? String(Array(path)[1...]) : path
        return newPath.safeFileName
    }
}

public extension String {
    var safeFileName: String {
        guard !isEmpty else { return "_" }
        let filename = self.replacingOccurrences(of: "^/", with: "", options: .regularExpression)
        return filename.replacingOccurrences(of: "[/\\* <>?%|.:]", with: "_", options: .regularExpression)
    }
}

private extension Stub {
    var name: String {
        var name: String
        if let path = request.url?.path, !path.isEmpty {
            name = path
        } else {
            name = "_"
        }
        
        if let query = request.url?.query {
            if !name.hasSuffix("_") { name += "_" }
            name += query
        }
        
        if name.count > Constants.maxFilenamePartLength {
            name = "\(name.prefix(Constants.maxFilenamePartLength))_\(name.hashValue)"
        }
        
        return name.safeFileName
    }
    
    var fileExtension: String {
        let ext: String
        if let mimeType = response?.mimeType, let mimeTypeExt = URL.pathExtension(for: mimeType) {
            ext = mimeTypeExt
        } else if let pathExt = request.url?.pathExtension, !pathExt.isEmpty {
            if pathExt.count > Constants.maxExtensionLength {
                ext = "\(pathExt.prefix(Constants.maxExtensionLength))_\(pathExt.djb2hash)"
            } else {
                ext = pathExt
            }
        } else {
            ext = "txt"
        }
        return ext
    }
}
