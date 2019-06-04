//
//
//  AssetResourceLoader.swift
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

import AVFoundation

public enum AssetResource {
    static let internalScheme = "cplp"
    static let redirectScheme = "rdtp"
    static let httpScheme = "http"
    static let redirectStatusCode = 302
    static let badRequestErrorCode = 400
    
    public enum DataError: Error {
        case noData(String)
    }
}

public class AssetResourceLoader: NSObject, AVAssetResourceLoaderDelegate {
    
    private let stubManager: StubManager
    private let port: Int
    
    public typealias loadSessionData = (_ url: URL, _ loadingRequest: AVAssetResourceLoadingRequest, _ httpResponse: HTTPURLResponse, _ sessionData: Data) -> Void
    
    private let playlist = HlsPlaylist()
    
    private lazy var session: URLSession = {
        return URLSession(configuration: self.configuration, delegate: self, delegateQueue: nil)
    }()
    
    private var configuration: URLSessionConfiguration
    
    public init(configuration: URLSessionConfiguration, stubManager: StubManager, port: Int) {
        self.configuration = configuration
        self.stubManager = stubManager
        self.port = port
    }
    
    deinit {
        session.invalidateAndCancel()
    }
    
    /// Convenience method to set the AVURLAsset resourceLoader
    ///
    /// - Parameters:
    ///   - url: URL
    ///   - options: AVURLAsset options
    /// - Returns: AVURLAsset
    public func avAsset(with url: URL, options: [String: Any]? = nil) -> AVURLAsset {
        let internalUrl = url.url(with: AssetResource.internalScheme)
        let asset = AVURLAsset(url: internalUrl, options: options)
        asset.resourceLoader.setDelegate(self, queue: DispatchQueue(label: "com.mokten.assetresource")) // , qos: .utility, attributes: .concurrent
        return asset
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else { return false }
        
        if let scheme = url.scheme,
            scheme.hasPrefix(AssetResource.redirectScheme) {
            return loadRedirectRequest(loadingRequest)
        } else {
            return load(loadingRequest, loadSessionData: processSessionData)
        }
        
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        return load(renewalRequest, loadSessionData: processSessionData)
    }
    
    public func load(_ loadingRequest: AVAssetResourceLoadingRequest, loadSessionData: @escaping(loadSessionData)) -> Bool {
        guard var url = loadingRequest.request.url else {
            return false
        }
        
        url = url.url(with: AssetResource.httpScheme)
        var request = playlist.normalise(loadingRequest.request)
        request.url = url
        
        let task = session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                logger("AssetLoader ERROR", request, error!)
                loadingRequest.finishLoading(with: error!)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                loadingRequest.finishLoading(with: AssetResource.DataError.noData("Bad response \(url)"))
                return
            }
            
            guard let data = data else {
                loadingRequest.finishLoading(with: AssetResource.DataError.noData("\(url)"))
                return
            }
            
            logger("data=", data.count)
            
            
            loadSessionData(url, loadingRequest, httpResponse, data)
        }
        
        task.resume()
        
        return true
    }
    
    public func processSessionData(url: URL, loadingRequest: AVAssetResourceLoadingRequest, httpResponse: HTTPURLResponse, sessionData: Data) {
        logger()
        
        var data = sessionData
        
        //Handle m3u8 playlist
        if let mimeType = httpResponse.mimeType?.lowercased(),
            ["mpegurl"].contains(where: { mimeType.contains($0) }) {
            let baseURL = url.url(with: AssetResource.redirectScheme)
            let text = String(data: data, encoding: .utf8)
            
            if let updatedText = playlist.replace(text: text, with: AssetResource.redirectScheme, to: baseURL) {
                data = updatedText.data(using: .utf8) ?? data
            }
            
        }
        
        loadingRequest.dataRequest?.respond(with: data)
        loadingRequest.finishLoading()
    }
    
    public func loadRedirectRequest(_ loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        logger()
        return load(loadingRequest, loadSessionData: processRedirectData)
    }
    
    public func processRedirectData(url: URL, loadingRequest: AVAssetResourceLoadingRequest, httpResponse: HTTPURLResponse, sessionData: Data) {
        logger()
        
        // Apple deliberately makes loading from http
        var request = loadingRequest.request
        let originalURL = url.url(with: AssetResource.httpScheme)
        request.url = playlist.normalise(originalURL)
        
        if let stubRequest = request.stubRequest,
            let stub = self.stubManager.get(request: stubRequest),
            let url = stub.request.url,
            var comp = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            comp.scheme = "http"
            comp.host = "localhost"
            comp.port = port
            comp.path = "/stub"
        
            comp.query = "url=\(originalURL.absoluteString)"

            if let newURL = comp.url {
                request.url = newURL
            }
            
        }
        
        loadingRequest.redirect = request
        loadingRequest.response = HTTPURLResponse(url: request.url!,
                                                  statusCode: AssetResource.redirectStatusCode,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: nil)
        loadingRequest.finishLoading()
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForResponseTo authenticationChallenge: URLAuthenticationChallenge) -> Bool {
        return true
    }
}

extension AssetResourceLoader: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(request)
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        logger("didBecomeInvalidWithError", error.debugDescription)
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let protectionSpace = challenge.protectionSpace
        let sender = challenge.sender
        
        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                sender?.use(credential, for: challenge)
                completionHandler(.useCredential, credential)
                return
            }
        }
        
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

