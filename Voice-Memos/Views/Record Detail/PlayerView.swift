//
//  PlayerView.swift
//  Voice-Memos
//
//  Created by Isaque da Silva on 1/10/26.
//

import SwiftUI

struct PlayerView: View {
    let fileURL: URL
    var deleteFileAction: (URL) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(AudioController.self) private var audioController
    @State private var isShowingDeleteAlert = false
    @State private var error: AppErrorProtocol? = nil
    @State private var isShowingErrorAlert = false
    
    
    var body: some View {
        NavigationStack {
            @Bindable var controller = audioController
            
            VStack {
                BarVisualizerView(
                    values: controller.meterLevelHistory,
                    barCount: 24
                )
                .frame(height: 60)
                
                ProgressBarView(
                    currentTime: controller.currentTime,
                    progress: controller.progress
                )
                
                PlayButton(state: controller.currentState) {
                    self.play()
                } pause: {
                    controller.pausePlayback()
                } resume: {
                    controller.resumeAudio()
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
                        isShowingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .alert("Delete record", isPresented: $isShowingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteRecord()
                }
            } message: {
                Text("Are you sure that you want to delete this audio record?")
            }
            .alert(error?.title ?? "", isPresented: $isShowingErrorAlert) {
                Button("OK") {
                    self.error = nil
                }
            } message: {
                if let error, let description = error.description {
                    Text(description)
                }
            }
        }
    }
    
    private func play() {
        do {
            try audioController.playPlayback(at: fileURL)
        } catch let error as AppErrorProtocol {
            self.error = error
            self.isShowingErrorAlert = true
        } catch {
            self.error = DefaultUnknownError()
            self.isShowingErrorAlert = true
        }
    }
    
    private func deleteRecord() {
        do {
            try StorageHandler.removeContent(at: fileURL)
            deleteFileAction(fileURL)
            dismiss()
        } catch let error as AppErrorProtocol {
            self.error = error
            self.isShowingDeleteAlert = true
        } catch {
            self.error = DefaultUnknownError()
            self.isShowingDeleteAlert = true
        }
    }
}

#Preview {
    PlayerView(fileURL: .init(string: "example.com")!) { _ in }
        .environment(AudioController.shared)
}

