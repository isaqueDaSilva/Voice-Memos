//
//  RecorderView.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/5/26.
//

import SwiftUI

struct RecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AudioController.self) private var audioController
    @State private var isShowingAlert = false
    @State private var isShowingErrorAlert = false
    @State private var error: AppError? = nil
    
    var appendNewRecordURL: (URL) -> Void
    
    var body: some View {
        NavigationStack {
            @Bindable var controller = audioController
            let isRecording = controller.currentState == .recording
            
            VStack {
                BarVisualizerView(
                    values: isRecording ? controller.meterLevelHistory : [],
                    barCount: 24
                )
                .frame(height: 60)
                
                SoundIntensityMeterView(
                    meterLevel: isRecording ? controller.meterLevel : 0,
                    currentTime: isRecording ? controller.currentTime : 0
                )
                
                RecorderButton(state: controller.state) {
                    do {
                        try controller.start()
                    } catch let error as AppError {
                        self.error = error
                        self.isShowingErrorAlert = true
                    } catch {
                        self.error = DefaultUnknownError()
                        self.isShowingErrorAlert = true
                    }
                } stop: {
                    controller.stop()
                }
                
                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Record")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        if let url = controller.fileURL {
                            appendNewRecordURL(url)
                            controller.removeURL()
                        }
                        
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if controller.fileURL != nil {
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
                    do {
                        if let fileURL = controller.fileURL {
                            try StorageHandler.removeContent(at: fileURL)
                        }
                        
                        dismiss()
                    } catch let error as AudioControllerError {
                        self.error = error
                    } catch {
                        self.error = DefaultUnknownError()
                    }
                }
            }
            .task {
                await controller.requestPermition()
            }
        }
    }
}

#Preview {
    RecorderView { _ in }
}
