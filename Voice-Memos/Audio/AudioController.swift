//
//  AudioController.swift
//  Voice-Memos
//
//  Created by Isaque da Silva on 1/5/26.
//

import AVFoundation
import Combine
import Foundation

typealias RecordPermission = AVAudioApplication.recordPermission

@MainActor
@Observable
final class AudioController {
    static let shared = AudioController()
    
    private(set) var fileURL: URL?
    private(set) var state: AudioControllerState = .notInitialized
    var currentState: AudioControllerState { state }
    private var mediaController: MediaController? = nil
    private var mediaTimer: AnyCancellable?
    var currentTime: TimeInterval = 0
    var progress: Double = 0
    
    var meterLevel: Float = 0
    var meterLevelHistory: [Float] = []
    private var meterTimeObserver: AnyCancellable?
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            
            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .audio)
            }
            
            return isAuthorized
        }
    }
    
    private func handleWithTimer(with controller: MediaController) {
        mediaTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                
                if let player = controller as? AVAudioPlayer {
                    if player.isPerformingAction {
                        self.currentTime = player.currentTime
                        self.progress = (player.currentTime / player.duration)
                    }
                    
                    if player.currentTime == 0 {
                        removePlayer()
                    }
                }
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
    private func createDirectory() throws(StorageHandlerError) {
        self.fileURL = try StorageHandler.createDirectoryURL()
    }
    
    private func setupRecording(with fileURL: URL) throws {
        // Definig the setting of how we want that the microfone capture the audio.
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM), // uncompressed audio format, to preserve the original signal with high fidelity
            AVLinearPCMIsNonInterleaved: true, // Each channel will be saved at your specific memory buffer to signal processing
            AVSampleRateKey: 44_100, // Sample the audio by default's 44.1kHz frequency
            AVNumberOfChannelsKey: 2, // record stereo audio.
            AVLinearPCMBitDepthKey: 16 // how many bits per sample.
        ]
        
        mediaController = try AVAudioRecorder(url: fileURL, settings: settings)
        
        if let recorder = mediaController as? AVAudioRecorder {
            recorder.isMeteringEnabled = true
            
            if recorder.prepareToRecord() {
                recorder.record()
                state = .recording
                handleWithTimer(with: recorder)
                startMetering()
            }
        }
    }
    
    private func record() throws {
        mediaController?.stop()
        
        #if os(iOS)
        try self.setupSession()
        #endif

        try createDirectory()

        if let fileURL {
            try setupRecording(with: fileURL)
        }
    }
    
    func startRecord() async throws {
        guard await self.isAuthorized else {
             throw AudioControllerError.microfoneNotAlowed
        }
        
        try await MainActor.run { [weak self] in
            guard let self else { return }
            try self.record()
        }
    }
    
    func pauseRecord() {
        if let recorder = mediaController as? AVAudioRecorder {
            recorder.pause()
            state = .paused
        }
    }
    
    func resumeRecord() {
        if let recorder = mediaController as? AVAudioRecorder {
            recorder.record()
            state = .recording
        }
    }
    
    func deleteRecord() {
        if let recorder = mediaController as? AVAudioRecorder {
            if recorder.isRecording {
                stopRecording()
                recorder.deleteRecording()
            }
        }
    }
    
    // Stops recording and calls the completion callback when the recording finishes.
    func stopRecording() {
        mediaController?.stop()
        state = .notInitialized
        mediaTimer?.cancel()
        mediaTimer = nil
        mediaController = nil
        stopMetering()
        print("Finish cleanup")
    }
}

// MARK: - Play audio
extension AudioController {
    private func prepareToPlay(with fileURL: URL) {
        mediaController = try? AVAudioPlayer(contentsOf: fileURL)
        
        if let player = mediaController as? AVAudioPlayer {
            player.isMeteringEnabled = true
            
            if player.prepareToPlay() {
                player.play()
                state = .playing
                handleWithTimer(with: player)
                startMetering()
            }
        }
    }
    
    func playPlayback(at fileURL: URL) throws {
        mediaController?.stop()
        
        prepareToPlay(with: fileURL)
    }
    
    func pausePlayback() {
        if let player = mediaController as? AVAudioPlayer {
            player.pause()
            state = .paused
        }
    }
    
    func resumeAudio() {
        if let player = mediaController as? AVAudioPlayer {
            player.play()
            state = .playing
        }
    }
    
    func removePlayer() {
        mediaController?.stop()
        mediaTimer?.cancel()
        mediaTimer = nil
        state = .notInitialized
        currentTime = 0
        progress = 0
        mediaController = nil
        stopMetering()
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
                
                if meterable.isPerformingAction {
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
        meterLevelHistory.removeAll()
        meterLevel = 0
        currentTime = 0
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
            
            // Saying to the system that we want to start and record an audio using a buit in hardware of external device.
            // Note: `playAndRecord` category implies that we want to start a session that is nonmixable,
            // and no audio will interrupt the session.
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
        let suportedAudioDevices: [AVAudioSession.Port] = [.builtInMic, .headphones, .lineIn]
        
        guard let availableInputs = session.availableInputs,
              let builtinMics = availableInputs.first(where: { suportedAudioDevices.contains($0.portType)})
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
