//
//
//  URLExtension.swift
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
import MobileCoreServices

public extension URL {
    
    static func pathExtension(for mimeType: String) -> String {
        let mime = mimeType as NSString
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mime, nil)?.takeRetainedValue(),
            let fileExtension = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension)?.takeRetainedValue() else {
                return "txt"
        }
        return fileExtension as String
    }
    
    func url(with scheme: String) -> URL {
        let baseURL = self
        guard var comp = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return baseURL
        }
        
        if let baseScheme = comp.scheme, baseScheme.count >= scheme.count {
            let indexStart = baseScheme.index(baseScheme.startIndex, offsetBy: scheme.count)
            let endStr = baseScheme[indexStart...]
            comp.scheme = scheme + endStr
        } else {
            comp.scheme = scheme
        }
        
        return comp.url ?? baseURL
    }
    
    func deletingParam(_ name:String) -> URL {
        guard let _ = self.query?.contains(name),
            var comp = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = comp.queryItems else {
                return self
        }
        
        comp.queryItems = queryItems.filter({ $0.name != name })
        return comp.url ?? self
    }
}

extension URLRequest {
    init(url: URL, httpMethod: String) {
        self.init(url: url)
        self.httpMethod = httpMethod
    }
}
