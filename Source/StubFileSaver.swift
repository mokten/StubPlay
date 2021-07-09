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

/*
 Saves a Stub in a format
 */
public protocol StubSaver {
    func save(_ stub: Stub, bodyData: Data?, completion: ((Result<Stub?, Error>) -> Void)?)
}

/*
 
 Saves a Stub in a two files.
 
 The reason it is saved in two files is that one file contains the request/response meta data and the second file is the actual content.
 
 This means no extraction needs to be performed and the file can be viewed directly in a compatible viewer.
 
 ie. jpeg can be viewed in a jpeg viewer
 
 1. Request and response meta data
 2. Response body ie. image, json, html, video
 
 */
public class StubFileSaver: StubSaver {
    
    private let filesManager: FilesManagable
    private let filenameFormatter: FilenameFormatter
    private let responseDataFileNameFormatter: FilenameFormatter
    
    // Keeps count of the request
    private let counter = Counter<Request>()
    private let queue = DispatchQueue(label: "com.mokten.stubplay.stubfilesaver")
    
    /// Saves a Stub locally in two files
    ///
    /// - Parameters:
    ///   - filesManager: Responsible for saving the files
    ///   - filenameFormatter: formats the file names
    ///   - ResponseDataFileNameFormatter: formats the body file name
    public init(filesManager: FilesManagable,
                filenameFormatter: FilenameFormatter = DefaultFilenameFormatter(),
                responseDataFileNameFormatter: FilenameFormatter = ResponseDataFileNameFormatter()) {
        self.filesManager = filesManager
        self.filenameFormatter = filenameFormatter
        self.responseDataFileNameFormatter = responseDataFileNameFormatter
    }
    
    public func save(_ stub: Stub, bodyData: Data?, completion: ((Result<Stub?, Error>) -> Void)? = nil) {
        queue.async { [weak self] in
            guard let self = self else { return }
            do {
                var stub = stub
                if stub.index == 0 {
                    stub.index = self.counter.count(for: stub.request)
                }
                let filename = self.filenameFormatter.filename(for: stub)
                let responseDataFileName: String? = bodyData != nil ? self.responseDataFileNameFormatter.filename(for: stub) : nil
                stub.responseDataFileName = responseDataFileName
                stub.responseData = nil
                
                self.filesManager.save(stub, to: filename)
                if let bodyData = bodyData, let responseDataFileName = responseDataFileName {
                    try self.filesManager.save(data: bodyData, to: responseDataFileName)
                }
                
                completion?(.success(stub))
            } catch {
                //TODO:
                logger(error: error)
                completion?(.failure(error))
            }
        }
    }
    
    public func clear() {
         queue.async { [weak self] in
            try? self?.filesManager.clear()
        }
    }
}
