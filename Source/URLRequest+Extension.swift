//
//  URLRequest+Extension.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/5/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

extension URLRequest {
    
    /// Converts httpBodyStream to Data. If there is any error then returns nil
    func httpBodyStreamData() -> Data? {
        guard let input = self.httpBodyStream else { return nil }

        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

        input.open()
        defer {
            input.close()
            buffer.deallocate()
        }

        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                //Stream error occured
                return nil
            } else if read == 0 {
                //EOF
                break
            }
            data.append(buffer, count: read)
        }

        return data
    }

    func httpBodyStreamString() -> String? {
        guard let data = httpBodyStreamData() else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func stubRequest(url: URL?) -> Request? {
        guard let url = url else { return nil }
        
        let method: HttpMethod
        if let methodLower = httpMethod?.lowercased(), let httpMethod = HttpMethod(rawValue: methodLower) {
            method = httpMethod
        } else {
            method = .get
        }
        
        // TODO: Check image/count max ?
        let body: String?
        if let httpBody = httpBody, httpBody.count > 0 {
            body = String(data: httpBody, encoding: .utf8)
        } else if let streamBody = httpBodyStreamString() {
            // TODO: this is iffy...
            body = streamBody
        } else {
            body = nil
        }
        
        return Request(method: method, url: url, headers: self.allHTTPHeaderFields, body: body)
    }
    
    var stubRequest: Request? {
        return stubRequest(url: url)
    } 
}
