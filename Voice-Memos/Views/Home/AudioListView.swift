//
//  AudioListView.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/5/26.
//

import SwiftUI

struct AudioListView: View {
    @Binding var selection: URL?
    var audios: [URL]
    var deleteAudio: (URL) -> Void
    
    var body: some View {
        if audios.isEmpty {
            ContentUnavailableView(
                "No audio files recorded yet.",
                systemImage: "waveform.slash",
                description: .init("Click on '+' button and create one.")
            )
        } else {
            List(audios, id: \.self, selection: $selection) { audio in
                VStack(alignment: .leading) {
                    Text("Record: \(audio.lastPathComponent)")
                        .font(.subheadline)
                }
                .tag(audio)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deleteAudio(audio)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
}

#Preview {
    AudioListView(
        selection: .constant(nil),
        audios: []
    ) { _ in}
}
