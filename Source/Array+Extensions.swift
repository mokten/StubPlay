//
//  Array+Extensions.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 26/6/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

extension Array {

    /*
     
     Example:
     
     names[-1, default: "Anonymous"]
     
     */
    public subscript(index: Int, default defaultValue: @autoclosure () -> Element) -> Element {
        guard index >= 0, index < endIndex else {
            return defaultValue()
        }
        
        return self[index]
    }
    
    /*
     
     Example:
     
     names[safe: -1]
     */
    public subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}
