//
//  PlayButton.swift
//  Voice-Memos
//
//  Created by Isaque da Silva on 1/10/26.
//

import SwiftUI

struct PlayButton: View {
    let state: AudioControllerState
    var start: () -> Void
    var pause: () -> Void
    var resume: () -> Void
    
    private var systemImageName: String {
        switch state {
        case .paused, .notInitialized:
            return "play.fill"
        case .playing, .recording:
            return "pause.fill"
        }
    }
    
    var body: some View {
        Button {
            switch state {
            case .notInitialized:
                start()
            case .paused:
                resume()
            case .playing:
                pause()
            case .recording:
                break
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
    PlayButton(state: .paused) { } pause: { } resume: { }
}
