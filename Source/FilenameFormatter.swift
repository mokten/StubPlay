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

public protocol FilenameFormatter {
    func filename(for stub: Stub) -> String
}

public struct DefaultFilenameFormatter: FilenameFormatter {
    
    public init() { }
    
    public func filename(for stub: Stub) -> String {
        return "\(stub.name).\(stub.request.method.rawValue).\(stub.index).json"
    }
}

public struct ResponseDataFileNameFormatter: FilenameFormatter {
    
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
        safeFileName()
    }
    
    func safeFileName(replaceWith: String = "_") -> String {
        guard !isEmpty else { return "_" }
        let filename = self.replacingOccurrences(of: "^/", with: "", options: .regularExpression)
        let name = filename.replacingOccurrences(of: "[/\\* <>?%|.:()]", with: replaceWith, options: .regularExpression)
        return name == "" ? replaceWith : name
    }
}
