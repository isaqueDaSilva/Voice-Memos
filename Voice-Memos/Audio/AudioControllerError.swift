//
//  AudioControllerError.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/9/26.
//

import Foundation

enum AudioControllerError: AppError {
    case noMicrophoneAvailable
    case failedToCreateSession
    case failedToSetupBuitInMicrophone
    case failedToStartRecord
    case noFileToPlay
    case microfoneNotAlowed
    
    var title: String {
        switch self {
        case .noMicrophoneAvailable:
            return "No Microfone available"
        case .failedToCreateSession:
            return "Failed to create session"
        case .failedToSetupBuitInMicrophone:
            return "Failed to setup microfone"
        case .failedToStartRecord:
            return "Failed to start record"
        case .noFileToPlay:
            return "No file to play"
        case .microfoneNotAlowed:
            return "Microfone not allowed"
        }
    }
    
    var description: String? {
        switch self {
        case .noMicrophoneAvailable:
            return "No microfone is available on your device. Try to reload the app and try again."
        case .failedToCreateSession:
            return "Comunication with the audio system failed. Try to reload the app and try again."
        case .failedToSetupBuitInMicrophone:
            return "Failed to setup built in microfone to perform the best recording. Try to reload the app and try again."
        case .failedToStartRecord:
            return "Failed to start recording. Try to reload the app and try again."
        case .noFileToPlay:
            return "Please, select an file to start play."
        case .microfoneNotAlowed:
            return "Microfone access is not allowed. Please, allow it in settings."
        }
    }
}
