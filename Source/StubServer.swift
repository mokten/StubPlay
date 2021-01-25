//
//
//  StubServer.swift
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
#if canImport(Swifter)
import Swifter
#endif

public class StubServer {
    
    private let stubManager: StubManager
    private var server: HttpServer?
    
    init(stubManager: StubManager) {
        self.stubManager = stubManager
    }
    
    public func start(port: in_port_t) throws {
        let server = HttpServer()
        server["/stub"] = shareFilesFromDirectory()
        try server.start(port)
        self.server = server
    }
    
    public func shareFilesFromDirectory() -> ((HttpRequest) -> HttpResponse) {
        return { [weak self] request in
            guard let self = self,
                let stubRequest = request.stubRequest,
                let stub = self.stubManager.get(request: stubRequest),
                let response = stub.response
                else {
                return .notFound
            }
            
            let statusCode = response.statusCode ?? 200
            
            guard let data = stub.bodyData else {
                return .raw(statusCode, "OK", response.headers, nil)
            }
            
            return .raw(statusCode, "OK", response.headers, { writer in
                try? writer.write(data)
            })
        }
    }
    
    func stop() {
        server?.stop()
        server = nil
    }
}

extension HttpRequest {
    var stubRequest: Request? {
        let method =  HttpMethod(rawValue: self.method.lowercased()) ?? .get
        guard let queryParam = queryParams.first else { return nil }
        let urlStr = queryParam.1
        guard let url = URL(string: urlStr) else { return nil }
        
        // TODO: Check image/count max ?
        let requestBody: String?
        if body.count > 0 {
            requestBody = String(bytes: body, encoding: .utf8)
        } else {
            requestBody = nil
        }
        
        return Request(method: method, url: url, headers: headers, body: requestBody)
    }
}
