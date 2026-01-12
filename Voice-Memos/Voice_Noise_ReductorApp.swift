//
//  Voice_Noise_ReductorApp.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/4/26.
//

import SwiftUI

@main
struct Voice_Noise_ReductorApp: App {
    @State private var audioController = AudioController.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(audioController)
        }
    }
}
