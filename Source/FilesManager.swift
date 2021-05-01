//
//
//  FilesManager.swift
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

public enum FilesManagerError: Error, Equatable {
    case cannotDeleteDirectoryToCreateFile(String)
    case fileDoesNotExist(String)
    case noDataAtPath(String)
    case couldNotCreateFile(String)
}

// Saves/Reads files locally
public struct FilesManager {
    
    private enum Constants {
        static let baseDir = "com.mokten.stubplay"
    }
    
    public static let defaultSaveDirURL: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        .first!.appendingPathComponent(Constants.baseDir)
    
    public let bundle: Bundle
    
    public let saveDirectoryURL: URL?
}

extension FilesManager {
    
    public init(bundle: Bundle = Bundle.main, saveDirectoyURL: URL? = FilesManager.defaultSaveDirURL) {
        self.bundle = bundle
        self.saveDirectoryURL = saveDirectoyURL
        
        logger(saveDirectoryURL)
        
        if let saveDirectoyURL = saveDirectoyURL {
            do {
                try FileManager.default.createDirectory(at: saveDirectoyURL, withIntermediateDirectories: true, attributes: [:])
            } catch {
                fatalError("Could not create URL at directory: \(saveDirectoyURL)")
            }
        }
    }
    
    public func bundleUrl(for resource: String) -> URL? {
        return bundle.url(forResource: resource, withExtension: nil)
    }
    
    public func url(for resource: String) -> URL? {
        guard let saveURL = saveDirectoryURL else { return nil }
        return saveURL.appendingPathComponent(resource)
    }
    
    public func urls(at dir: URL) -> [URL]? {
        return try? FileManager.default.contentsOfDirectory(at: dir,
                                                            includingPropertiesForKeys: [],
                                                            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants])
    }
    
    public func urls(at resource: String) ->[URL]? {
        guard let folder = bundleUrl(for: resource) else { return nil }
        return urls(at: folder)
    }
    
    public func bundleData(for resource: String, inDirectory: String? = nil) throws -> Data? {
        guard let path = bundle.path(forResource: resource, ofType: nil, inDirectory: inDirectory) else {
            return nil            
        }
        return FileManager.default.contents(atPath: path)
    }
    
    public func data(from url: URL) throws -> Data? {
        return FileManager.default.contents(atPath: url.path)
    }
    
    public func save(data: Data?, to fileName: String) throws -> URL? {
        guard let saveURL = saveDirectoryURL else { return nil }
        let url = saveURL.appendingPathComponent(fileName, isDirectory: false)
        try data?.write(to: url, options: .atomic)
        return url
    }
    
    /// Remove all files at specified directory
    public func clear() throws {
        guard let saveURL = saveDirectoryURL else { return }
        let contents = try FileManager.default.contentsOfDirectory(at: saveURL, includingPropertiesForKeys: nil, options: [])
        for fileUrl in contents {
            try FileManager.default.removeItem(at: fileUrl)
        }
    }
    
    public func create(directory: URL) throws {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [:])
    }
}

// MARK: - Encodable Decodable Helpers

public extension FilesManager {
    func save<T: Encodable>(_ object: T, to fileName: String) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(object)
            _ = try self.save(data: data, to: fileName)
        } catch {
            // TODO:
            logger(level: .error, error)
        }
    }
    
    func get<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        guard let fileData = try data(from: url) else {
            throw FilesManagerError.noDataAtPath(url.path)
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: fileData)
        } catch {
            logger(level: .error, "Error! \(url.absoluteString): \(String(data:fileData, encoding: .utf8) ?? "")")
            throw error
        }
    }
}
