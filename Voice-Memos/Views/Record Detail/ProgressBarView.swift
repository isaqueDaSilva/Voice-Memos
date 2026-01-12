//
//  ProgressBarView.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/10/26.
//

import SwiftUI

struct ProgressBarView: View {
    let currentTime: TimeInterval
    let progress: Double
    
    var body: some View {
        VStack {
            ProgressView(value: progress)
                .progressViewStyle(.linear)
            
            Text(currentTime.toTimeLabel())
                .font(.headline.monospaced())
        }
    }
}

#Preview {
    ProgressBarView(currentTime: 24, progress: 0.4)
}
