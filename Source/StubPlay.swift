//
//
//  StubPlay.swift
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

public enum StubPlayConstants {
    public static let serverPort: in_port_t = 9080
}

public class StubPlay {
    
    public static let `default` = StubPlay()
    public let stubManager: StubManager
    private var isEnabled = false
    
    public let serverPort: in_port_t
    
    private var isEnabledServer = false {
        didSet {
            guard oldValue != isEnabledServer else { return }
            if isEnabledServer {
                if self.stubServer == nil {
                    self.stubServer = StubServer(stubManager: stubManager)
                }
            } else {
                self.stubServer?.stop()
            }
        }
    }

    public var stubServer: StubServer? = nil
    
    public var saveResponse: Bool = false
    
    init(stubManager: StubManager = StubManager.shared, serverPort: in_port_t = StubPlayConstants.serverPort) {
        self.stubManager = stubManager
        self.serverPort = serverPort
    }
    
    public func enableStub(_ enable: Bool = true, isEnabledServer: Bool = false) throws {
        guard isEnabled != enable else { return }
        isEnabled = enable
        self.isEnabledServer = isEnabledServer
        
        if isEnabled {
            if isEnabledServer {
                try stubServer?.start(port: StubPlayConstants.serverPort)
            }
            URLCache.shared.removeAllCachedResponses()
            URLProtocol.registerClass(StubURLProtocol.self)
        } else {
            stubServer?.stop()
            URLProtocol.unregisterClass(StubURLProtocol.self)
        }
        
        swizzleProtocolClasses()
    }
}

public enum StubPlayError: LocalizedError {
    case stubCacheLoad(Error?, StubFolderCache?, String?)
}
