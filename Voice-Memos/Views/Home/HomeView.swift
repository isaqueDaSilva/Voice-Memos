//
//  HomeView.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/4/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(AudioController.self) private var controller
    @State private var recordURLs: [URL] = []
    @State private var selectedURL: URL? = nil
    @State private var isShowingCreateANewRecordView: Bool = false
    @State private var isShowingAlert = false
    @State private var error: AppError? = nil
    
    var body: some View {
        NavigationSplitView {
            AudioListView(
                selection: $selectedURL,
                audios: recordURLs
            ) { fileURL in
                recordURLs.removeAll(where: { $0 == fileURL })
            }
            .navigationTitle("All Recordings")
            .toolbar {
                Button {
                    isShowingCreateANewRecordView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $isShowingCreateANewRecordView) {
                RecorderView { newRecordURL in
                    self.recordURLs.insert(newRecordURL, at: 0)
                }
                .presentationDetents([.medium])
            }
            .onAppear {
                do {
                    self.recordURLs = try StorageHandler.getFilesURLs()
                } catch let error as AppError {
                    isShowingAlert = true
                    self.error = error
                } catch {
                    isShowingAlert = true
                    self.error = DefaultUnknownError()
                }
            }
            .alert(error?.title ?? "", isPresented: $isShowingAlert) {
                Button("OK") { }
            } message: {
                if let error, let description = error.description {
                    Text(description)
                }
            }
            .onChange(of: selectedURL) { oldValue, newValue in
                if( oldValue != nil && newValue == nil) || newValue != oldValue {
                    controller.resetState()
                }
            }
        } detail: {
            if let selectedURL {
                PlayerView(fileURL: selectedURL) { fileURL in
                    recordURLs.removeAll(where: { $0 == fileURL })
                }
            } else {
                ContentUnavailableView(
                    "No record is selected",
                    systemImage: "waveform.slash"
                )
            }
        }

    }
}

#Preview {
    HomeView()
}
