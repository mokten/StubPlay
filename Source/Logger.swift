//
//  Logger.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 23/5/19.
//  Copyright © 2019 Mokten Pty Ltd. All rights reserved.
//

import Foundation

func logger(_ items: Any?..., separator: String = " ", terminator: String = "\n", _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if !DISABLE_LOG
    
    struct Log {
        static let dtFmt: DateFormatter = {
            let dtFmt = DateFormatter()
            dtFmt.dateFormat = "HH:mm:ss.SSS"
            return dtFmt
        }()
        
        static func currentFileName(_ fileName: String = #file) -> String {
            var str = String(describing: fileName)
            if let idx = str.range(of: "/", options: .backwards)?.upperBound {
                str = String(str[idx...])
            }
            if let idx = str.range(of: ".", options: .backwards)?.lowerBound {
                str = String(str[..<idx])
            }
            return str
        }
    }
    
    let stringItem = items.map { "\(String(describing: $0))" }.joined(separator: separator)
    
    print("\(Log.dtFmt.string(from: Date())) \(Log.currentFileName(file)).\(function)[\(line)]: \(stringItem)", terminator: terminator)
    #endif
}

