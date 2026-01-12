//
//  PlayerView.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/10/26.
//

import SwiftUI

struct PlayerView: View {
    let fileURL: URL
    var deleteFileAction: (URL) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(AudioController.self) private var audioController
    @State private var isShowingError = false
    @State private var error: AppError? = nil
    @State private var isShowingAlert = false
    
    
    var body: some View {
        NavigationStack {
            @Bindable var controller = audioController
            let isPlaying = controller.currentState == .playing
            
            VStack {
                BarVisualizerView(
                    values: isPlaying ? controller.meterLevelHistory : [],
                    barCount: 24
                )
                .frame(height: 60)
                
                ProgressBarView(
                    currentTime: isPlaying ? controller.currentTime : 0,
                    progress: isPlaying ? controller.progress : 0
                )
                
                PlayButton(state: controller.currentState) {
                    try? controller.start(with: fileURL)
                } stop: {
                    controller.stop()
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle(fileURL.lastPathComponent)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationBarBackButtonHidden()
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        controller.removePlayer()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                #endif
                
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        isShowingAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .alert("Delete record", isPresented: $isShowingAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    do {
                        try StorageHandler.removeContent(at: fileURL)
                        deleteFileAction(fileURL)
                        dismiss()
                    } catch let error as AppError {
                        self.error = error
                        self.isShowingError = true
                    } catch {
                        self.error = DefaultUnknownError()
                        self.isShowingError = true
                    }
                }
            } message: {
                Text("Are you sure that you want to delete this audio record?")
            }
            .alert(error?.title ?? "", isPresented: $isShowingError) {
                Button("OK") { }
            } message: {
                if let error, let description = error.description {
                    Text(description)
                }
            }
        }
    }
}

#Preview {
    PlayerView(fileURL: .init(string: "example.com")!) { _ in }
}
