//
//
//  URLSessionConfigurationExtension.swift
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

public extension URLSessionConfiguration {
    
    func enableStub(_ isEnabled: Bool) {
        guard var protocolClasses = protocolClasses else {
            self.protocolClasses = [StubURLProtocol.self]
            return
        }
        
        let protoCls: AnyClass = StubURLProtocol.self
        if isEnabled && !protocolClasses.contains(where: { $0 == protoCls }) {
            protocolClasses.insert(protoCls, at: 0)
        } else if !(isEnabled && protocolClasses.contains(where: { $0 == protoCls })),
            let index = protocolClasses.firstIndex(where: { $0 == protoCls }) {
            protocolClasses.remove(at: index)
        }
        
        self.protocolClasses = protocolClasses
    }
}
