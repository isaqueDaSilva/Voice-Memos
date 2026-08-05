//
//  RecorderView.swift
//  Voice-Memos
//
//  Created by Isaque da Silva on 1/5/26.
//

import SwiftUI

struct RecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AudioController.self) private var audioController
    @State private var isShowingAlert = false
    @State private var isShowingErrorAlert = false
    @State private var error: AppErrorProtocol? = nil
    
    var appendNewRecordURL: (URL) -> Void
    
    var body: some View {
        NavigationStack {
            @Bindable var controller = audioController
            
            VStack {
                BarVisualizerView(
                    values: controller.meterLevelHistory,
                    barCount: 24
                )
                .frame(height: 60)
                
                CurrentTimeView(
                    currentTime: controller.currentTime
                )
                
                RecorderButton(state: controller.state) {
                    startRecording()
                } stop: {
                    controller.stopRecording()
                    addNewRecord()
                } pause: {
                    controller.pauseRecord()
                } resume: {
                    controller.resumeRecord()
                }

                
                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Record")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if controller.fileURL != nil {
                            controller.pauseRecord()
                            isShowingAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .alert(error?.title ?? "", isPresented: $isShowingErrorAlert) {
                Button("OK") { }
            } message: {
                if let error, let description = error.description {
                    Text(description)
                }
            }
            .alert("Record Deletion", isPresented: $isShowingAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                   deleteRecord()
                }
            }
        }
    }
    
    private func startRecording() {
        Task {
            do {
                try await audioController.startRecord()
            } catch let error as AppErrorProtocol {
                self.error = error
                self.isShowingErrorAlert = true
            } catch {
                self.error = DefaultUnknownError()
                self.isShowingErrorAlert = true
            }
        }
    }
    
    private func deleteRecord() {
        do {
            audioController.deleteRecord()
            
            if let fileURL = audioController.fileURL {
                try StorageHandler.removeContent(at: fileURL)
            }
            
            dismiss()
        } catch {
            self.error = error
            isShowingErrorAlert = true
        }
    }
    
    private func addNewRecord() {
        if let url = audioController.fileURL {
            appendNewRecordURL(url)
            audioController.removeURL()
        }
        
        dismiss()
    }
}

#Preview {
    RecorderView { _ in }
        .environment(AudioController.shared)
}

