//
//  WebSocket.swift
//  Example-iOS
//
//  Created by Yoo-Jin Lee on 27/3/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

protocol WebSocket {
    func connect(_ request: NSMutableURLRequest)
    func disconnect()
}

@available(iOS 13.0, *)
class WebSocket13: NSObject, WebSocket {
    private let session: URLSession
    
    // WebSocket
    private var socket: URLSessionWebSocketTask!
    
    private let handleData: (Data) -> Void
    private let handleString: (String) -> Void
    private let handleError: (Error) -> Void
    
    init(session: URLSession,
         handleData: @escaping (Data) -> Void,
         handleString: @escaping (String) -> Void,
         handleError: @escaping (Error) -> Void) {
        self.session = session
        self.handleData = handleData
        self.handleString = handleString
        self.handleError = handleError
    }
    
    func connect(_ request: NSMutableURLRequest) {
        guard let url = request.url,
              var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        
        comps.scheme = comps.scheme?.replacingOccurrences(of: "http", with: "ws")
        request.url = comps.url
        
        let headers = request.allHTTPHeaderFields
        request.setValue(nil, forHTTPHeaderField: "Upgrade")
        request.setValue(nil, forHTTPHeaderField: "Connection")
        request.setValue(nil, forHTTPHeaderField: "Sec-WebSocket-Key")
        request.setValue(nil, forHTTPHeaderField: "Sec-WebSocket-Protocol")
        request.setValue(nil, forHTTPHeaderField: "Sec-WebSocket-Version")
        
//        if request.value(forKey: "Upgrade") != nil {
//            request.setValue(nil, forHTTPHeaderField: "Upgrade")
//        }
//
//        if request.value(forKey: "Connection") != nil {
//            request.setValue(nil, forHTTPHeaderField: "Connection")
//        }
//
//        if request.value(forKey: "Sec-WebSocket-Key") != nil {
//            request.setValue(nil, forHTTPHeaderField: "Sec-WebSocket-Key")
//        }
//
//        if request.value(forKey: "Sec-WebSocket-Protocol") != nil {
//            request.setValue(nil, forHTTPHeaderField: "Sec-WebSocket-Protocol")
//        }
//
//        if request.value(forKey: "Sec-WebSocket-Version") != nil {
//            request.setValue(nil, forHTTPHeaderField: "Sec-WebSocket-Version")
//        }
        
//        var mReq = NSMutableURLRequest(url: comps.url!)
//        URLProtocol.setProperty(true, forKey: CustomURLConst.requestHeaderKey, in: newRequest)
        
        let newRequest = request as URLRequest
        
        self.socket = session.webSocketTask(with: newRequest)
        
//        self.socket = session.webSocketTask(with: request.url!)
        
        self.listen()
        self.socket.resume()
    }
    
    func disconnect() {
        socket.cancel(with: .normalClosure, reason: nil)
    }
    
    private func listen() {
        self.socket.receive { [weak self] (result) in
            guard let self = self else { return }
            // 2
            switch result {
            case .failure(let error):
                print(error)
                self.handleError(error)
                return
            case .success(let message):
                switch message {
                case .data(let data):
                    self.handleData(data)
                case .string(let str):
                    self.handleString(str)
                @unknown default:
                    break
                }
            }
            self.listen()
        }
    }
}
@available(iOS 13.0, *)
extension WebSocket13: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Connected!")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Disconnected!")
    }
}

class WebSocketManager {
    static func make(session: URLSession,
                     handleData: @escaping (Data) -> Void,
                     handleString: @escaping (String) -> Void,
                     handleError: @escaping (Error) -> Void) -> WebSocket? {
        if #available(iOS 13, *) {
            return WebSocket13(session: session, handleData: handleData, handleString: handleString, handleError: handleError)
        }
        return nil
    }
}

public class StubURLProtocol: URLProtocol {
    
    private enum CustomURLConst {
        static let requestHeaderKey = "StubPlayRequestHeader"
    }
    
    private lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }()
    
    private let stubManager = StubManager.shared
    private var dataTask: URLSessionDataTask?
    private var responseData: Data?
    
    private var websocket: WebSocket?
    
    // MARK: NSURLProtocol
    
    override public class func canInit(with request: URLRequest) -> Bool {
        
        if request.isWebSocket {
            logger(request, request.allHTTPHeaderFields)
            return false
        }
        
        logger(request)
        return URLProtocol.property(forKey: CustomURLConst.requestHeaderKey, in: request as URLRequest) == nil
    }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override public func startLoading() {
        if let stubRequest = request.stubRequest, let stub = stubManager.get(request: stubRequest) {
            logger("MOCK:", request.url)
            finished(stub: stub, response: stub.httpURLResponse(defaultURL: request.url), bodyData: stub.bodyData, isCached: true)
            
        } else {
            logger("NETWORK:", request.url)
            guard let newRequest = request as? NSMutableURLRequest else { return }
            URLProtocol.setProperty(true, forKey: CustomURLConst.requestHeaderKey, in: newRequest)
            
            if request.isWebSocket {
                logger(newRequest)
                let websocket = WebSocketManager.make(session: session,
                                                      handleData: { data in
                                                        logger(String(data: data, encoding: .utf8))
                                                      }, handleString: { str in
                                                        logger(str)
                                                      }, handleError: { error in
                                                        logger(error)
                                                      })
                self.websocket = websocket
                websocket?.connect(newRequest)
                
                
            } else {
                let dataTask = session.dataTask(with: newRequest as URLRequest)
                dataTask.resume()
                self.dataTask = dataTask
            }
        }
    }
    
    override public func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
        //        websocket?.disconnect()
        //        websocket = nil
        responseData = nil
    }
}


