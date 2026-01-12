//
//  PlayButton.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/10/26.
//

import SwiftUI

struct PlayButton: View {
    let state: AudioControllerState
    var start: () -> Void
    var stop: () -> Void
    
    private var systemImageName: String {
        switch state {
        case .stopped, .recording:
            return "play.fill"
        case .playing:
            return "pause.fill"
        }
    }
    
    var body: some View {
        Button {
            if state == .playing {
                stop()
            } else {
                start()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 72, height: 72)
                Image(systemName: systemImageName)
                    .foregroundStyle(.white)
                    .font(.system(size: 28, weight: .bold))
            }
        }
        .buttonStyle(.plain)
        .padding(.top)
    }
}

#Preview {
    PlayButton(state: .stopped) { } stop: { }
}
