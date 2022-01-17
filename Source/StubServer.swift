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
import Swifter

public class StubServer {
    
    private let stubManager: StubManager
    private var server: HttpServer?
    private var port: in_port_t = StubPlayConstants.serverPort
    private let playlist = HlsPlaylist()
    
    init(stubManager: StubManager) {
        self.stubManager = stubManager
    }
    
    @discardableResult
    public func start(port: in_port_t) throws -> String {
        self.port = port
        let server = HttpServer()
        server[StubPlayConstants.serverPath] = shareFilesFromDirectory()
        try server.start(port, priority: .userInteractive)
        self.server = server
        return ipAddress
    }
    
    public func shareFilesFromDirectory() -> ((HttpRequest) -> HttpResponse) {
        return { [weak self] request in
            
            guard let self = self,
                  let stubRequest = request.stubRequest,
                  let stub = self.stubManager.get(request: stubRequest, isChangeIndex: false),
                  let response = stub.response
            else {
                return .notFound()
            }
            
            let statusCode = response.statusCode ?? 200
            var headers = response.headers
            var data = stub.responseData
            
            if let contentType = headers?[caseInsensitive: "Content-Type"],
               contentType.lowercased().contains("mpegurl"),
               let m3u8Data = data,
               let text = String(data: m3u8Data, encoding: .utf8)
            {
                let baseURL = stub.request.url.url(with: AssetResource.httpScheme)
                
                if let updatedText = self.playlist.replace(text: text,
                                                           with: AssetResource.redirectScheme,
                                                           to: baseURL,
                                                           stubURL: URL(string: "http://127.0.0.1:\(Int(self.port))\(StubPlayConstants.serverPath)")) {
                    data = updatedText.data(using: .utf8)
                }
            }
            
            if headers?[caseInsensitive: "Content-Encoding"] != nil {
                headers?[caseInsensitive: "Content-Encoding"] = nil
            }
            
            if headers?[caseInsensitive: "Content-Length"] != nil, let data = stub.responseData {
                headers?[caseInsensitive: "Content-Length"] = "\(data.count)"
            }
            
            return .raw(statusCode, "OK", headers, { writer in
                do {
                    if let data = data {
                        try writer.write(data)
                    }
                } catch {
                    logger(error: error)
                }
            })
        }
    }
    
    public func stop() {
        server?.stop()
        server = nil
    }
}

extension StubServer {
    public var ipAddress: String {
        return "http://" + Network.ipAddress + ":\(port)"
    }
}

private extension HttpRequest {
    var stubRequest: Request? {
        let method =  HttpMethod(rawValue: self.method.lowercased()) ?? .get
        guard let urlStr = queryParams.first?.1.removingPercentEncoding else { return nil }
        
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
