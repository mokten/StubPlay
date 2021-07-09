//
//  String+Stream.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 9/7/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

extension String {
    func isStream() -> Bool {
        return self.contains(".mp3") || self.contains(".m3u8") || self.contains(".aac")
    }
}

extension URL {
    func isStream() -> Bool {
        return scheme == AssetResource.internalScheme || scheme == AssetResource.redirectScheme || path.isStream()
    }
}

extension URLRequest {
    func isStream() -> Bool {
        guard let url = url else { return false }
        return url.isStream()
    }
}
