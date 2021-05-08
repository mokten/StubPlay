//
//  Stub+Name.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 8/5/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

private enum Constants {
    static let maxExtensionLength = 10
    static let maxFilenamePartLength = 100
}

extension Stub {
    /**
     Creates a file save name for the Stub
     
     https://localhost/ -> _
     https://localhost/? -> _
     
     */
    var name: String {
        var name: String
        if let path = request.url?.path, !path.isEmpty {
            name = path
        } else {
            name = "_"
        }
        
        if let query = request.url?.query {
            if !name.hasSuffix("_") { name += "_" }
            name += query
        }
        
        if let body = request.body {
            if name != "_" {
                name += "_"
            }
            name += "\(body.djb2hash)"
        }
        
        if name.count > Constants.maxFilenamePartLength {
            name = "\(name.prefix(Constants.maxFilenamePartLength))_\(name.djb2hash)"
        }
        
        return name.safeFileName
    }
    
    var fileExtension: String {
        let ext: String
        if let mimeType = response?.mimeType, let mimeTypeExt = URL.pathExtension(for: mimeType) {
            ext = mimeTypeExt
        } else if let pathExt = request.url?.pathExtension, !pathExt.isEmpty {
            if pathExt.count > Constants.maxExtensionLength {
                ext = "\(pathExt.prefix(Constants.maxExtensionLength))_\(pathExt.djb2hash)"
            } else {
                ext = pathExt
            }
        } else {
            ext = "txt"
        }
        return ext
    }
}
