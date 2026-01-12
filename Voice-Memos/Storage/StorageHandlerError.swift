//
//  StorageHandlerError.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/10/26.
//

import Foundation

enum StorageHandlerError: AppError {
    case noDirectoryFound
    case failedToCreateDirectory
    case failedToGetFileURLs
    case failedToDeleteFile
    case unknown
    
    var title: String {
        switch self {
        case .noDirectoryFound:
            return "No directory found."
        case .failedToCreateDirectory:
            return "Failed to create directory."
        case .failedToGetFileURLs:
            return "Failed to get file URLs."
        case .failedToDeleteFile:
            return "Failed to delete file."
        case .unknown:
            return "Unknown error."
        }
    }
    
    var description: String? {
        switch self {
        case .noDirectoryFound:
            return "No directroy found to save your audio."
        case .failedToCreateDirectory:
            return "Failed to create a directory to save your audio."
        case .failedToGetFileURLs:
            return ""
        case .failedToDeleteFile:
            return ""
        case .unknown:
            return "An unknown error occured. Pleae try to reload the app and try again."
        }
    }
}
