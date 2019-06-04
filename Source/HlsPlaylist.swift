//
//
//  HlsPlaylist.swift
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

public protocol HlsPlaylistTransform {
    func replace(text: String?, with scheme: String, to baseUrl: URL) -> String?
}

public class HlsPlaylist: HlsPlaylistTransform {
    
    enum HlsPlaylistConst {
        static let byteRangeKey = "mpx-range"
    }
    
    public init() { }
    
    public func replace(text: String?, with scheme: String, to baseUrl: URL) -> String? {
        guard let text = text else { return nil }
        
        let lines = text.components(separatedBy: .newlines)
        var buffer = ""
        
        var lastByteRange: String?
        
        for (i, line) in lines.enumerated() {
            let newLine = line.trimmingCharacters(in: .whitespaces)
            
            if newLine.hasPrefix("#EXT-X-BYTERANGE:") {
                // #EXT-X-BYTERANGE:75232@0
                // Range: bytes=326744-653111
                lastByteRange = byteRange(for: newLine)
                
                buffer += newLine
                
            } else if newLine.hasPrefix("#EXT-X-KEY:") {
                buffer += replaceKeyURI(line: newLine, with: "scheme", to: baseUrl)
                
            } else if newLine.hasPrefix("#") {
                buffer += newLine
                
            } else if newLine.hasPrefix(scheme) || newLine.hasSuffix("m3u8") {
                buffer += append(to: newLine, name: HlsPlaylistConst.byteRangeKey, value: lastByteRange)
                
            } else {
                buffer += replace(line: newLine, with: scheme, to: baseUrl, with: lastByteRange)
                lastByteRange = nil
            }
            
            if i < (lines.count - 1) {
                buffer += "\n"
            }
        }
        
        return buffer
    }
    
    // Expected line: #EXT-X-BYTERANGE:2238516@0
    public func byteRange(for line: String?) -> String? {
        guard let line = line else { return nil }
        
        let range = line.matches(for: "(\\d+)")
        
        guard range.count == 2,
            let lengthRangeInt = Int(range[0]), lengthRangeInt > 0,
            let startRangeInt = Int(range[1]), startRangeInt >= 0 else {
                return nil
        }
        
        let endRange = startRangeInt + lengthRangeInt - 1
        
        return "\(startRangeInt)-\(endRange)"
    }
    
    public func replace(line: String, with scheme: String, to baseURL: URL, with byteRange: String? = nil) -> String {
        var newLine = line.trimmingCharacters(in: .whitespaces)
        
        guard newLine.count != 0 && !newLine.hasPrefix(scheme) else {
            return append(to: newLine, name: HlsPlaylistConst.byteRangeKey, value: byteRange)
        }
        
        if newLine.lowercased().hasPrefix("http") {
            newLine = newLine.replacingOccurrences(of: "^http", with: scheme, options: .regularExpression)
            
        } else if let relativeURL = URL(string: newLine, relativeTo: baseURL)?.standardized {
            newLine = relativeURL.absoluteString
        }
        
        return append(to: newLine, name: HlsPlaylistConst.byteRangeKey, value: byteRange)
    }
    
    func append(to uri: String, name: String, value: String?) -> String {
        
        guard let value = value, var comp = URLComponents(string: uri) else {
            return uri
        }
        
        var queryItems = comp.queryItems ?? []
        queryItems.append(URLQueryItem(name: name, value: value))
        comp.queryItems = queryItems
        
        return comp.url?.absoluteString ?? uri
    }
    
    // #EXT-X-KEY:METHOD=SAMPLE-AES,URI="http://mysite.com/my16ByteKey.bin",KEYFORMAT="identity",IV=0xA30FE123ECBF1BE323A775A119C553BC
    public func replaceKeyURI(line: String, with scheme: String, to baseUrl: URL) -> String {
        
        let matches = line.matches(for: "(.*,URI=\")(?:([^\\\"]+))(\".*)")
        
        guard matches.count == 3 else { return line }
        
        var uri = matches[1]
        
        if uri.lowercased().hasPrefix("http") || uri.hasPrefix(".") || uri.hasPrefix("/") {
            uri = replace(line: uri, with: scheme, to: baseUrl)
        }
        
        return matches[0] + uri + matches[2]
    }
    
    // moves query header params to request header
    public func normalise(_ request: URLRequest) -> URLRequest {
        guard let url = request.url, let _ = url.query?.contains(HlsPlaylistConst.byteRangeKey),
            var comp = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = comp.queryItems,
            let rangeQueryItem = queryItems.filter({ $0.name == HlsPlaylistConst.byteRangeKey }).first,
            let bytes = rangeQueryItem.value else {
                return request
        }
        
        comp.queryItems = queryItems.filter({ $0.name != HlsPlaylistConst.byteRangeKey })
        
        guard let newUrl = comp.url else {
            return request
        }
        
        var newRequest = request
        newRequest.url = newUrl
        var allHTTPHeaderFields = newRequest.allHTTPHeaderFields ?? [:]
        allHTTPHeaderFields["Range"] = "bytes=\(bytes)"
        newRequest.allHTTPHeaderFields = allHTTPHeaderFields
        
        return newRequest
    }
    
    public func normalise(_ url: URL) -> URL {
        return url.deletingParam(HlsPlaylistConst.byteRangeKey)
    }
    
}

