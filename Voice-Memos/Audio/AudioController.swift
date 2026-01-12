//
//  AudioController.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/5/26.
//

import AVFoundation
import Combine
import Foundation

@MainActor
@Observable
final class AudioController {
    static let shared = AudioController()
    
    private(set) var fileURL: URL?
    
    var meterLevel: Float = 0
    var meterLevelHistory: [Float] = []
    
    private var playerTimer: AnyCancellable?
    var currentTime: TimeInterval = 0
    var progress: Double = 0
    
    private var mediaController: MediaController?
    
    private var meterTimeObserver: AnyCancellable?
    private(set) var state: AudioControllerState = .stopped
    var currentState: AudioControllerState { state }
    
    var isMicrofonePermited = false
    
    func requestPermition() async {
        let isMicrofonePermited = await AVAudioApplication.requestRecordPermission()
        
        await MainActor.run { [weak self] in
            guard let self else { return }
            
            self.isMicrofonePermited = isMicrofonePermited
        }
    }
    
    func start(with fileURL: URL? = nil, completation: @escaping () -> Void = {}) throws(AudioControllerError) {
        if let fileURL {
            self.fileURL = fileURL
            play()
        } else {
            guard isMicrofonePermited else { completation(); throw .noMicrophoneAvailable }
            
            record()
        }
    }
    
    func stop() {
        if (mediaController is AVAudioPlayer) {
            stopPlayback()
        } else if (mediaController is AVAudioRecorder) {
            stopRecording()
        }
    }
    
    func resetState() {
        if (mediaController is AVAudioPlayer) {
            removePlayer()
        } else if (mediaController is AVAudioRecorder) {
            stopRecording()
        }
        
        removeURL()
    }
    
    func removeURL() {
        fileURL = nil
    }
    
    private init() { }
}

// MARK: - Record audio
extension AudioController {
    private func record() {
        mediaController?.stop()
        
        do {
            #if os(iOS)
            try self.setupSession()
            #endif
            
            let url = try StorageHandler.createDirectoryURL()
            fileURL = url
            
            // Definig the setting of how we want that the microfone capture the audio.
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM), // uncompressed audio format, to preserve the original signal with high fidelity
                AVLinearPCMIsNonInterleaved: false, // Save the audio with a single buffer data of the channels. (Note: Change this for DSP)
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 2, // record stereo audio.
                AVLinearPCMBitDepthKey: 16 // how many bits per sample.
            ]
            
            mediaController = try AVAudioRecorder(url: url, settings: settings)
            
            if let recorder = mediaController as? AVAudioRecorder {
                recorder.isMeteringEnabled = true
                
                if recorder.prepareToRecord() {
                    recorder.record()
                    state = .recording
                    startMetering()
                }
            }
        } catch {
            print("Failed to start record. Error: \(error.localizedDescription)")
        }
    }
    
    // Stops recording and calls the completion callback when the recording finishes.
    private func stopRecording() {
        mediaController?.stop()
        state = .stopped
        mediaController = nil
        stopMetering()
    }
}

// MARK: - Play audio
extension AudioController {
    private func play() {
        mediaController?.stop()
        
        guard let fileURL else { print("No recording to play"); return }
        mediaController = try? AVAudioPlayer(contentsOf: fileURL)
        
        if let player = mediaController as? AVAudioPlayer {
            player.isMeteringEnabled = true
            
            if player.prepareToPlay() {
                player.play()
                state = .playing
                startMetering()
                handleWithProgress(with: player)
            }
        }
    }
    
    private func handleWithProgress(with player: AVAudioPlayer) {
        playerTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                
                self.currentTime = player.currentTime
                self.progress = (player.currentTime / player.duration)
                
                if player.currentTime == 0 {
                    removePlayer()
                }
            }
    }
    
    private func stopPlayback() {
        guard let player = mediaController as? AVAudioPlayer else { print("Wrong media controller setted"); return }
        
        player.pause()
        state = .stopped
        stopMetering()
    }
    
    func removePlayer() {
        mediaController?.stop()
        playerTimer?.cancel()
        playerTimer = nil
        state = .stopped
        currentTime = 0
        progress = 0
        stopMetering()
        mediaController = nil
        
        print("Finish cleanup")
    }
}

// MARK: - Metering
extension AudioController {
    private func startMetering() {
        let meterable: MediaController? = if let mediaController, let recorder = mediaController as? AVAudioRecorder, recorder.isRecording {
            recorder
        } else if let mediaController, let player = mediaController as? AVAudioPlayer, player.isPlaying {
            player
        } else {
            nil
        }
        
        guard meterable != nil else { return }
        
        meterTimeObserver?.cancel()
        
        meterTimeObserver = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let meterable, meterable.isPerformingAction else { return }
                
                meterable.updateMeters()
                
                self.currentTime = meterable.currentTime
                let ch0 = Self.normalize(meterable.averagePower(forChannel: 0))
                let ch1 = Self.normalize(meterable.averagePower(forChannel: 1))
                let combined = (ch0 + ch1) / 2
                self.meterLevel = combined
                self.meterLevelHistory.append(combined)
                
                if self.meterLevelHistory.count > 100 {
                    self.meterLevelHistory.removeFirst(self.meterLevelHistory.count - 100)
                }
            }
    }
    
    private static func normalize(_ dBFS: Float) -> Float {
        let floor: Float = -60 // Human threshold of hearing in decibeis full scale
        if dBFS < floor { return 0 } // cleanup sound power that has values bellow of -60 dBFS
        let clamped: Float = max(min(dBFS, 0), floor)
        return (clamped - floor) / -floor
    }
    
    private func stopMetering() {
        meterTimeObserver?.cancel()
        meterTimeObserver = nil
        meterLevel = 0
        currentTime = 0
        meterLevelHistory.removeAll()
    }
}

// MARK: - iOS Setup
#if os(iOS)
extension AudioController {
    private func setupSession() throws(AudioControllerError) {
        try createSession()
        try setupBuiltinMicrophone()
    }
    
    private func createSession() throws(AudioControllerError) {
        do {
            // Creating a new session.
            let session = AVAudioSession.sharedInstance()
            
            // Saying to the system that we want to play and record an audion using a buit in hardware of the device
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
            
            // Set to active the audio session.
            try session.setActive(true)
        } catch {
            print("Failed to set up the audio session. Error: \(error.localizedDescription)")
            throw .failedToCreateSession
        }
    }
    
    private func setupBuiltinMicrophone() throws(AudioControllerError) {
        let session = AVAudioSession.sharedInstance()
        
        guard let availableInputs = session.availableInputs,
              let builtinMics = availableInputs.first(where: { $0.portType == .builtInMic })
        else {
            throw .noMicrophoneAvailable
        }
        
        do {
            try session.setPreferredInput(builtinMics)
        } catch {
            print("Failed to set up the builtin microphone. Error: \(error.localizedDescription)")
            throw .failedToSetupBuitInMicrophone
        }
    }
}

#endif
