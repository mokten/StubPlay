//
//  FileManager+Archive.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 13/1/2023.
//  Copyright © 2023 Mokten Pty Ltd. All rights reserved.
//

import Foundation

public enum ArchiveError: Error {
    case missingSaveResponsesDirURL
    case archiveError(Error)
    case archiveCouldNotMove(error: Error, message: String)
}

public extension FileManager {

    /// Archives the contents in the fromDirectory and saves it to toURL
    ///
    /// - Parameters:
    ///   - fromDirectory: URL of a directory to archive
    ///   - toURL: URL to save the archive file to
    ///   - completion: Completion block on status of the archive
    func archiveStubs(fromDirectory: URL, toURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        if fileExists(atPath: toURL.path) {
            try? removeItem(at: toURL)
        }
        
        let coordinator = NSFileCoordinator()
        let zipIntent = NSFileAccessIntent.readingIntent(with: fromDirectory, options: [.forUploading])
        coordinator.coordinate(with: [zipIntent], queue: .main) { error in
            if let error {
                completion(.failure(ArchiveError.archiveError(error)))
                return
            }
            
            do {
                try self.moveItem(at: zipIntent.url, to: toURL)
                completion(.success(toURL))
            } catch {
                completion(.failure(ArchiveError.archiveCouldNotMove(error: error, message: "ERROR moving \(zipIntent.url) to \(toURL):")))
            }
            
        }
    }
}
