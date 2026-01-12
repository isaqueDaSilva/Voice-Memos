//
//  RecorderButton.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/9/26.
//

import SwiftUI

struct RecorderButton: View {
    let state: AudioControllerState
    var start: () -> Void
    var stop: () -> Void
    
    private var recordingSymbol: String {
        switch state {
        case .stopped, .playing:
            return "mic.circle.fill"
        case .recording:
            return "pause.circle.fill"
        }
    }
    
    private var recorderButtonLabel: String {
        switch state {
        case .stopped:
            return "Record"
        case .recording, .playing:
            return "Pause"
        }
    }
    
    var body: some View {
        Button {
            if state == .recording || state == .playing {
                stop()
            } else {
                start()
            }
        } label: {
            Label(recorderButtonLabel, systemImage: recordingSymbol)
                .font(.system(size: 48, weight: .semibold, design: .default))
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
        .tint(.accentColor)
        .padding(.top, 16)
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: state)
    }
}

#Preview {
    RecorderButton(state: .stopped) {
    } stop: { }
}
