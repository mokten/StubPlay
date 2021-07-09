//
//  Logger.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 23/5/19.
//  Copyright © 2019 Mokten Pty Ltd. All rights reserved.
//

import Foundation

public class Logger: NSObject {
    
    enum Level {
        case debug, warn, error
    }
    
    public static let shared = Logger()
    
    public var isEnabled: Bool = false
    
    fileprivate static let dtFmt: DateFormatter = {
        let dtFmt = DateFormatter()
        dtFmt.dateFormat = "HH:mm:ss.SSS"
        return dtFmt
    }()
    
    fileprivate static func currentFileName(_ fileName: String = #file) -> String {
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

func logger(error: Error, separator: String = " ", terminator: String = "\n", _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    logger(level: .error, error, separator: separator, terminator: terminator, file, function, line)
}

func logger(isLog: (() -> Bool)? = nil, level: Logger.Level = .debug, _ items: Any?..., separator: String = " ", terminator: String = "\n", _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    if let isLog = isLog, !isLog() { return }
    guard Logger.shared.isEnabled || level != .debug else { return }
    
    let stringItem = items.map {
        guard let item = $0 else { return "nil" }
        return "\(item)"
    }.joined(separator: separator)
    
    print("\(Logger.dtFmt.string(from: Date())) \(Logger.currentFileName(file)).\(function)[\(line)]: \(stringItem)", terminator: terminator)
}
