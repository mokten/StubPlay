//
//  FilesManagableStub.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 17/6/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import XCTest
@testable import StubPlay

class FilesManagableStub: FilesManagable {
    func bundleUrl(for resource: String) -> URL? {
        return URL(string: resource)
    }
    
    func url(for resource: String) -> URL? {
        return nil
    }
    
    func urls(at dir: URL) throws -> [URL]? {
        return []
    }
    
    func urls(at resource: String) throws -> [URL]? {
         return []
    }
    
    func bundlePath(for resource: String, inDirectory: String?) -> String? {
        return nil
    }
    
    func bundleResourceExists(for resource: String, inDirectory: String?) throws -> Bool {
        return true
    }
    
    func bundleData(for resource: String, inDirectory: String?) throws -> Data? {
         return nil
    }
    
    func data(from url: URL) throws -> Data? {
         return nil
    }
    
    func save(data: Data?, to fileName: String) throws -> URL? {
        return nil
    }
    
    func clear() throws {
    }
    
    func create(directory: URL) throws {
    }
    
    func save<T>(_ object: T, to fileName: String) where T : Encodable {
    }
    
    func get<T>(_ type: T.Type, from url: URL) throws -> T where T : Decodable {
        fatalError("Not implemented")
    }
    

}
