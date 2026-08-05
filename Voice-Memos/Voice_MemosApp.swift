//
//  Voice_MemosApp.swift
//  Voice-Memos
//
//  Created by Isaque da Silva on 7/21/26.
//

import SwiftUI

@main
struct Voice_MemosApp: App {
    @State private var audioController = AudioController.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(audioController)
        }
    }
}
