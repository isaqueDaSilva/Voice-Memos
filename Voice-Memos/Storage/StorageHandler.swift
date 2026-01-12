//
//  StorageHandler.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/9/26.
//

import Foundation

enum StorageHandler {
    static private func getDefaultDirectoryURL() throws(StorageHandlerError) -> URL {
        guard let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first
        else {
            throw .noDirectoryFound
        }
        
        return url.appending(component: "Recordings")
    }
    
    static private func getDirectoryURL() throws(StorageHandlerError) -> URL {
        let directory = try Self.getDefaultDirectoryURL().appending(component: "Recordings")
        
        do {
            if !FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            }
            
            return directory
        } catch {
            throw .failedToCreateDirectory
        }
    }
    
    static func createDirectoryURL() throws(StorageHandlerError) -> URL {
        let directory = try Self.getDirectoryURL()
        let timestamp = ISO8601DateFormatter().string(from: .now).replacingOccurrences(of: ":", with: "-")
        return directory.appending(path: "\(timestamp).wav")
    }
    
    static func getFilesURLs() throws(StorageHandlerError) -> [URL] {
        let directory = try Self.getDirectoryURL()
        
        do {
            return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
                .sorted(by: { $0.lastPathComponent > $1.lastPathComponent })
        } catch {
            throw .failedToGetFileURLs
        }
    }
    
    static func removeContent(at url: URL) throws(StorageHandlerError) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            throw .failedToDeleteFile
        }
    }
}
