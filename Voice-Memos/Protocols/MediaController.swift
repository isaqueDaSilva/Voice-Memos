//
//  MediaController.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/11/26.
//

import AVFoundation
import Foundation

// Adapter interface for player and recorder.
protocol MediaController {
    var isPerformingAction: Bool { get }
    var currentTime: TimeInterval { get }
    func updateMeters()
    func averagePower(forChannel channelNumber: Int) -> Float
    func stop()
}

extension AVAudioRecorder: MediaController {
    var isPerformingAction: Bool { self.isRecording }
}
extension AVAudioPlayer: MediaController {
    var isPerformingAction: Bool { self.isPlaying }
}
