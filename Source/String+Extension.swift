//
//  StringExtension.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 2018-05-13.
//  Copyright © 2018 Mokten Pty Ltd. All rights reserved.
//

import Foundation

extension String {
    
    /// the file name without any directory or extension
    /// ie. /var/path/myFileName.swift -> myFileName
    ///
    var filename: String {
        let url = URL(fileURLWithPath: self, isDirectory: false)
        return url.lastPathComponent.replacingOccurrences(of: "\\.\(url.pathExtension)$", with: "", options: .regularExpression)
    }
    
    /**
     
     A unique hash vs a secure hash SHA256
     
     We just want a quick way to create a hash that's unique.
     
     */
    var djb2hash: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }
    
    func matches(for regex: String, options: NSRegularExpression.Options = []) -> [String] {
        let str = self
        var result: [String] = []
        do {
            let rx = try NSRegularExpression(pattern: regex, options: options)
            let matches = rx.matches(in: str, options: [], range: NSRange(location: 0, length: str.count))
            
            for match in matches {
                for n in 1..<match.numberOfRanges {
                    let range = match.range(at: n)
                    guard range.location != NSNotFound else {
                        continue
                    }
                    let r = str.index(str.startIndex, offsetBy: range.location)
                        ..< str.index(str.startIndex, offsetBy: range.location + range.length)
                    let s = String(str[r])
                    result.append(s)
                }
            }
            
        } catch { }
        
        return result
    }
    
}
