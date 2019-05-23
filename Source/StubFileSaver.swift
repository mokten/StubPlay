//
//
//  MessageFileSaver.swift
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

public class StubFileSaver: StubSaver {
    
    private let filesManager: FilesManager
    private let filenameFormatter: FilenameFormatter
    private let bodyFilenameFormatter: FilenameFormatter
    private let counter = Counter<Request>()
    private let queue = DispatchQueue(label: "com.mokten.stubplay.stubfilesaver", qos: .background)
    
    public init(filesManager: FilesManager,
                filenameFormatter: FilenameFormatter = DefaultFilenameFormatter(),
                bodyFilenameFormatter: FilenameFormatter = BodyFilenameFormatter()) {
        self.filesManager = filesManager
        self.filenameFormatter = filenameFormatter
        self.bodyFilenameFormatter = bodyFilenameFormatter
    }
    
    public func save(_ stub: Stub, bodyData: Data?) {
        queue.async {
            do {
                var msg = stub
                msg.index = self.counter.count(for: msg.request)
                let filename = self.filenameFormatter.filename(for: msg)
                let bodyFileName = self.bodyFilenameFormatter.filename(for: msg)
                msg.bodyFileName = bodyFileName
                msg.bodyData = nil
                
                self.filesManager.save(msg, to: filename)
                _ = try self.filesManager.save(data: bodyData, to: bodyFileName)
            } catch {
                //TODO:
                print(error)
            }
        }
    }
    
    public func clear() throws {
        try filesManager.clear()
    }
}
